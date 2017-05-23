local db = require("db")
local service = require("service")
local errorCode = require("error")

local mysqlInstance = db.newMysql()
local redisInstance = db.newRedis()

local logCode = service.insertLog(mysqlInstance)
local ipCode = service.isIpInBlackList(mysqlInstance,redisInstance)

if ipCode==errorCode["OK"] then
  --body...
  ngx.say("OK")
else
  ngx.say("ERROR")
end

ngx.location.capture(ngx.var.uri)

-- local redirect_url = ngx.var.scheme.."://"..ngx.var.host..":5000"..ngx.var.uri
--
-- if ngx.var.args ~= nil then
--     ngx.redirect( redirect_url.."?"..ngx.var.args , ngx.HTTP_MOVED_TEMPORARILY)
-- else
--     ngx.redirect( redirect_url , ngx.HTTP_MOVED_TEMPORARILY)
-- end
