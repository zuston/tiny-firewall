local redis = require("resty.redis")
local mysql = require "resty.mysql"

local _M = {

}
function _M.newRedis()
  -- redis.add_commands("sadd")
  local cache= redis:new()

  local ok,err = cache:connect("127.0.0.1",6379)

  if not ok then
    ngx.say("fail to connect",err)
    return -1
  end
  return cache
end

function _M.newMysql()
  local db, err = mysql:new()
  if not db then
      ngx.say("failed to instantiate mysql: ", err)
      return -1
  end
  local ok, err, errcode, sqlstate = db:connect{
                    host = "127.0.0.1",
                    port = 3306,
                    database = "tinyFirewall",
                    user = "root",
                    password = "shacha",
                    max_packet_size = 1024 * 1024 }

  if not ok then
      ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
      return -1
  end
  return db
end

return _M
