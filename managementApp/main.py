#!coding:utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')
from flask import Flask
from flask import request
from flask import render_template
from flask import abort, redirect, url_for, session

from service import baseService as bs

app = Flask(__name__,static_folder='TFstatic')

@app.route("/tf/login")
def login():
    return render_template("login.html")

@app.route("/tf/logout")
def logout():
    session.pop("managementUser",None)
    return redirect(url_for("login"))

@app.route("/tf/loginDo",methods=["POST","GET"])
def loginDo():
    username = request.form.get("username")
    pwd = request.form.get("pwd")
    if bs.validateLogin(username,pwd):
        session["managementUser"] = username
        return redirect(url_for("index",count=20,page=1))
    else:
        return render_template("login.html",error="please check your username and pwd")

@app.route("/tf/index/<int:count>/<int:page>")
def index(count,page):
    if "managementUser" in session:
        userInfo = session["managementUser"]
        logList,sumPage = bs.getLogList(count,(page-1)*count)

        return render_template("index.html",userInfo=userInfo,logList=logList,currentPage=page,sumPage=sumPage)
    else:
        return redirect(url_for("login"))

@app.route("/tf/black")
def black():
    if "managementUser" in session:
        userInfo = session["managementUser"]
        blacklist = bs.getBlackList()
        return render_template("black.html",userInfo=userInfo,blackList=blacklist)
    else:
        return redirect(url_for("login"))

@app.route("/tf/black/modify/<string:ip>",methods=["POST"])
def blackModify(ip):
    frequency = request.form.get("frequency")
    limited_type = request.form.get("limitedType")
    print frequency,limited_type
    res = bs.blackModify(frequency,limited_type,ip)
    print res
    return redirect(url_for("black"))


@app.route("/tf/black/delete/<string:ip>")
def blackDelete(ip):
    bs.blackDelete(ip)
    return redirect(url_for("black"))

@app.route("/tf/black/ban/<string:ip>")
def blackBan(ip):
    bs.blackBan(ip)
    return redirect(url_for("black"))

@app.route("/tf/black/add",methods=["POST"])
def blackAdd():
    ip = request.form.get("ip")
    frequency = request.form.get("frequency")
    limited_type = request.form.get("limitedType")
    res = bs.blackAdd(ip,frequency,limited_type)
    error = None
    if res is False:
        error = "have exsited"
        if "managementUser" in session:
            userInfo = session["managementUser"]
            blacklist = bs.getBlackList()
            return render_template("black.html",userInfo=userInfo,blackList=blacklist,error=error)

        else:
            return redirect(url_for("login"))
    return redirect(url_for("black"))

@app.route("/tf/setting")
def setting():
    if "managementUser" in session:
        name = session["managementUser"]
        userInfo = bs.getUserInfo(name)
        return render_template("setting.html",userInfo=userInfo)
    else:
        return redirect(url_for("login"))


@app.route("/tf/setting/updatePwd",methods=["POST"])
def updatePwd():
    username = request.form.get("username")
    pwd = request.form.get("pwd")
    bs.updatePwd(username,pwd)
    return redirect(url_for("setting"))

@app.route("/tf/anay")
def anay():
    if "managementUser" in session:
        userInfo = session["managementUser"]
        return render_template("anay.html",userInfo=userInfo)

    else:
        return redirect(url_for("login"))


@app.route("/tf/test")
def test():
    return render_template("black.html")


if __name__ == "__main__":
    app.secret_key = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT'
    app.run()
