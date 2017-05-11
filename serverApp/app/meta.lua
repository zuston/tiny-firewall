local _M = {

}

ngx.req.read_body()

local header = ngx.req.get_headers()
local user_agent = header["User-Agent"]
local referer = header["Referer"]


local arrive_time = ngx.now()

local req_method = ngx.req.get_method()

local ip = ngx.var.remote_addr

local uri = ngx.var.uri

local args = nil
if string.match(req_method,"GET") then
  args = ngx.req.get_uri_args()
else
  args = ngx.req.get_post_args()
end

_M = {
  ip = ip,
  user_agent = user_agent,
  referer = referer,
  time = arrive_time,
  method = req_method,
  uri = uri,
  args = args
}

return _M
