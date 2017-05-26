local meta = require "meta"
local cjson = require "cjson"
local error = require "error"

local _M = {

}

local ip = meta.ip
local user_agent = meta.user_agent
local referer = meta.referer
local time = meta.time
local method = meta.method
local uri = meta.uri
local args = meta.args

local ttime = (os.date("%Y-%m-%d %H:%M:%S",time))

function _M.insertLog(mysqlInstance)
  if uri == "/favicon.ico" then
    return error["IGNORED"]
  end

  local sql =
  string.format("insert into log(ip,user_agent,referer,time,method,uri,args) values(\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')",
  ip,user_agent,referer,ttime,method,uri,cjson.encode(args))

  local res, err, errcode, sqlstate = mysqlInstance:query(sql)
  if not err then
    return error["DBSUCCESS"]
  else
    return error["DBERROR"]
  end
end

-- ip+BL is key
-- 先查表，看对这个ip的操作(频次与类型),如果存在这个黑名单，则去查redis看存在次数
-- limited_type (0,1,2) 分别代表　分钟，天数，永久
-- frequency 的值代表限制访问的次数
function _M.isIpInBlackList(mysqlInstance,redisInstance)
  local sql = string.format("select count(*) as count from blacklist where ip = \'%s\' ",ip)
  local res,err,errcode,sqlstate = mysqlInstance:query(sql)
  if not res then
    -- execute sql error
    return error["DBERROR"]
  else
    if tonumber(res[1]["count"])==0 then
      return error["OK"]
    else
      local sql = string.format("select * from blacklist where ip = \'%s\' ",ip)
      local res,err,errcode,sqlstate = mysqlInstance:query(sql)

      local blacklistKey = ip.."BL"
      local limited_type = res[1]["limited_type"]
      local frequency = res[1]["frequency"]
      local redisRes,redisErr = redisInstance:get(blacklistKey)

      if limited_type==2 then
        --body...
        -- 直接封禁
        return error["NOTALLOWED"]
      end

      if redisRes==ngx.null then
        local limitedVisitedTime = 60
        if limited_type==0 then
          limitedVisitedTime = 60
        elseif limited_type==1 then
          limitedVisitedTime = 60*60*24
        else
          limitedVisitedTime = -1
        end
        redisInstance:set(blacklistKey,1)
        if limitedVisitedTime~=-1 then
          redisInstance:expire(blacklistKey,limitedVisitedTime)
        end

        return error["OK"]

      else
        -- 如果热更新，直接清空当前blacklist指定ip
        -- 数据存在的情况，判断是否限制次数超过限定值
        -- todo
        local tempVisitCount = tonumber(redisRes)

        if tempVisitCount == frequency then
            -- return error["OK"]

            return error["VISITEDMUCH"]
        else
            redisInstance:incr(blacklistKey)
            return error["OK"]
        end

      end

    end
  end
end

-- api 的开放热部署
function _M.isApiOpen()
  return
end

-- user_agent 的开放热部署
function _M.isUserAgentOpen()
  return
end

-- 忽略指定uri ip
local function isIgnore()
  return
end


return _M
