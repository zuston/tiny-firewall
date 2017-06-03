local uri = ngx.var.uri
local start,endd,pattern = string.find(uri,"/tf/(.*)")
local staticStart,staticEnd,staticPattern = string.find(uri,"/TFstatic/(.*)")
local filterStart,filterEnd,filterPattern = string.find(uri,"/vn/(.*)")

if pattern~=nil or staticPattern~=nil or filterPattern~=nil then
  ngx.var.backend = "127.0.0.1:5000"
else

  local s1,e1,pres1 = string.find(uri,"^(.*)html$")
  local s2,e2,pres2 = string.find(uri,"^(.*)js$")
  local s3,e3,pres3 = string.find(uri,"^(.*)css$")
  local s4,e4,pres4 = string.find(uri,"^(.*)map$")
  local s5,e5,pres5 = string.find(uri,"^(.*)jpg$")
  local s6,e6,pres6 = string.find(uri,"^(.*)png$")
  local s7,e7,pres7 = string.find(uri,"^(.*)ico$")


  if pres1~=nil or pres2~=nil or pres3~=nil or pres4~=nil or pres5~=nil or pres6~=nil or pres7~=nil then
    ngx.var.backend = "127.0.0.1:6699"
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
end
