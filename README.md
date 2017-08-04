# tiny-firewall
* 采用 openresty 的方式在 server 端进行拦截处理
* 过滤高频次检索请求，设置 ip 黑白名单，防止拖垮服务器
* 监控请求记录，针对性优化

## 部署方式
* install openresty
* cd nginx floder 
* cd sbin
* ./nginx -c tiny-firewall/serverApp/conf/nginx.conf
* 启动后打开 web 界面进行监控
