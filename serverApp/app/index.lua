local uri = ngx.var.uri
local start,endd,pattern = string.find(uri,"/tf/(.*)")
local staticStart,staticEnd,staticPattern = string.find(uri,"/TFstatic/(.*)")

if pattern~=nil or staticPattern~=nil then
  ngx.var.backend = "127.0.0.1:5000"
else
  local db = require("db")
  local service = require("service")
  local errorCode = require("error")

  local mysqlInstance = db.newMysql()
  local redisInstance = db.newRedis()

  local logCode = service.insertLog(mysqlInstance)
  local ipCode = service.isIpInBlackList(mysqlInstance,redisInstance)

  if ipCode==errorCode["OK"] then
    -- ngx.say("success")
    ngx.var.backend = "127.0.0.1:6699"
  else
    ngx.say("error,code:"..ipCode)
  end
end
