#!encoding=utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')
import Db

def getInstance():
    instance = Db.Db(host='localhost',user='root',password='zuston',dbname='tinyFirewall')
    return instance


def validateLogin(username,pwd):
    instance = getInstance()
    result = instance.execute("select * from admin where username='%s' and pwd='%s'"%(username,pwd))
    if len(result)==1:
        return True
    return False

def getUserInfo(name):
    return getInstance().execute("select * from admin where username='%s'"%name)[0]

def getLogList(count,minIp):
    instance = getInstance()
    logList = instance.execute("select * from log where id>%d order by id limit %d"%(minIp,count))
    sumCount = instance.execute("select count(*) as c from log")[0]["c"]

    # 总计页数
    sumPage = sumCount/count

    return logList,sumPage

def getBlackList():
    instance = getInstance()
    return instance.execute("select * from blacklist")


def blackModify(frequency,limited_type,ip):
    instance = getInstance()
    return instance.execute("update blacklist set frequency=%d ,limited_type=%d where ip='%s'"%(int(frequency),int(limited_type),ip))

def blackDelete(ip):
    instance = getInstance()
    return instance.execute("delete from blacklist where ip='%s'"%ip)

def blackBan(ip):
    return getInstance().execute("update blacklist set limited_type=2 where ip='%s'"%ip)

def blackAdd(ip,frequency,limited_type):
    instance = getInstance()
    count = instance.execute("select count(*) as c from blacklist where ip='%s'"%ip)[0]['c']
    if count>0:
        return False
    getInstance().execute("insert blacklist(ip,frequency,limited_type) values('%s',%d,%d)"%(ip,int(frequency),int(limited_type)))
    return True

def updatePwd(username,pwd):
    return getInstance().execute("update admin set pwd = '%s' where username='%s'"%(pwd,username))
