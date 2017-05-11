local db = require("db")
local service = require("service")

local mysqlInstance = db.newMysql()
local redisInstance = db.newRedis()

local res = service.insertLog(mysqlInstance)
ngx.say(res)
