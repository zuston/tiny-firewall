local db = require("db")
local service = require("service")

local mysqlInstance = db.newMysql()
local redisInstance = db.newRedis()

local logCode = service.insertLog(mysqlInstance)
local ipCode = service.isIpInBlackList(mysqlInstance,redisInstance)
ngx.say(ipCode)
