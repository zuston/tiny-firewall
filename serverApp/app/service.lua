local meta = require "meta"
local cjson = require "cjson"
local _M = {

}

local ip = meta.ip
local user_agent = meta.user_agent
local referer = meta.referer
local time = meta.time
local method = meta.method
local uri = meta.uri
local args = meta.args

function _M.insertLog(mysqlInstance)
  if uri == "/favicon.ico" then
    return -1
  end

  local sql =
  string.format("insert into log(ip,user_agent,referer,time,method,uri,args) values(\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')",
  ip,user_agent,referer,time,method,uri,cjson.encode(args))

  local res, err, errcode, sqlstate = mysqlInstance:query(sql)
  if not err then
    return 1
  end
  return 0
end

-- ip+BL is key
-- 先查表，看对这个ip的操作(频次与类型),如果存在这个黑名单，则去查redis看存在次数
-- limited_type (0,1,2) 分别代表　分钟，天数，永久
-- frequency 的值代表限制访问的次数
function _M.isIpInBlackList(mysqlInstance,redisInstance)
  local sql = string.format("select count(*) as count,* where ip = %s from blacklist limit 1",ip)
  local res,err,errcode,sqlstate = mysqlInstance.query(sql)
  if err then
    -- execute sql error
    return -1
  else
    if res[1]["count"]==0 then
      return 1
    else
      local blacklistKey = ip.."BL"
      local limited_type = res[1]["limited_type"]
      local frequency = res[1]["frequency"]
      local redisRes,redisErr = redisInstance:get(blacklistKey)

      if frequency==2 then
        --body...
        -- 直接封禁
        return 3
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
        redisInstance.set(blacklistKey,1)
        if limitedVisitedTime~=-1 then
          redisInstance.expire(blacklistKey,limitedVisitedTime)
        end

      else
        -- 数据存在的情况，判断是否限制次数超过限定值
        -- todo
        --
        local tempVisitTime = tonumber(redisRes)
        if tempVisitTime >= frequency then
            return 3
        else
            redisInstance.set(blacklistKey,tempVisitTime+1)
            return 1
        end
        
      end

    end
  end
end


return _M
