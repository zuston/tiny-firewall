local redis = require "resty.redis"
local mysql = require "resty.mysql"
local error = require "error"
local _M = {

}
function _M.newRedis()
  -- redis.add_commands("sadd")
  local cache= redis:new()

  local ok,err = cache:connect("127.0.0.1",6379)

  if not ok then
    ngx.say("fail to connect",err)
    return error["DBCONNECTERROR"]
  end
  return cache
end

function _M.newMysql()
  local db, err = mysql:new()
  if not db then
      ngx.say("failed to instantiate mysql: ", err)
      return error["DBCONNECTERROR"]

  end
  local ok, err, errcode, sqlstate = db:connect{
                    host = "127.0.0.1",
                    port = 3306,
                    database = "tinyFirewall",
                    user = "root",
                    password = "zuston",
                    max_packet_size = 1024 * 1024 }

  if not ok then
      ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
      return error["DBCONNECTERROR"]
  end
  return db
end

return _M
