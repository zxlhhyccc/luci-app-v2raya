
local m,s,o,o1
local fs = require "nixio.fs"
local SYS  = require "luci.sys"

m = Map("v2raya", translate("v2rayA"), translatef("Simple v2rayA switch."))

m:section(SimpleSection).template  = "v2raya/v2raya_status"

s = m:section(TypedSection, "v2raya")
s.anonymous=true
s.addremove=false

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = 0
o.rmempty = false

gui_address = s:option(Value, "address", translate("GUI access address"))
gui_address.description = translate("Use 0.0.0.0:2017 to monitor all access.")
gui_address.default = "http://127.0.0.1:2017"
gui_address.placeholder = "http://127.0.0.1:2017"
gui_address.rmempty = false

-- [[ Bin Path ]]--
v2ray_bin = s:option(Value, "v2ray_bin", translate("Bin Path"), translate("v2rayA Bin path if no bin please download"))
v2ray_bin.default     = "/usr/bin/v2raya"
v2ray_bin.datatype    = "string"
v2ray_bin.optional = false
v2ray_bin.rmempty=false

o.validate=function(self, value)
if value=="" then return nil end
if fs.stat(value,"type")=="dir" then
	fs.rmdir(value)
end
if fs.stat(value,"type")=="dir" then
	if (m.message) then
	m.message =m.message.."\nerror!bin path is a dir"
	else
	m.message ="error!bin path is a dir"
	end
	return nil
end 
return value
end

home = s:option(Value, "config", translate("Sv2rayA configuration directory"))
home.default = "/etc/v2raya"
home.placeholder = "/etc/v2raya"
home.rmempty = false

-- [[ Ipv6 Support ]]--
ipv6 = s:option(Value, "ipv6_support", translate("Ipv6 Support"))
ipv6.description = translate("Make sure your IPv6 network works fine before you turn it on.")
ipv6:value("auto", translate("AUTO"))
ipv6:value("on", translate("ON"))
ipv6:value("off", translate("OFF"))
ipv6.default = auto

-- [[ Log ]]--
log_file = s:option(Flag, "enable_logging", translate("Enable logging"))

log_file = s:option(Value, "log_file", translate("Log file"))
log_file:depends("enable_logging", "1")
log_file.default = "/tmp/v2raya.log"
log_file.placeholder = "/tmp/v2raya.log"

log_level = s:option(ListValue, "log_level", translate("Log Level"))
log_level:depends("enable_logging", "1")
log_level:value("trace",translate("Trace"))
log_level:value("debug",translate("Debug"))
log_level:value("info",translate("Info"))
log_level:value("warn",translate("Warning"))
log_level:value("error",translate("Error"))
log_level.default = "Info"

log_max_days = s:option(Value, "log_max_days", translate("Log Keepd Max Days"))
log_max_days:depends("enable_logging", "1")
log_max_days.description = translate("Maximum number of days to keep log files.")
log_max_days.datatype = "uinteger"
log_max_days.default = "3"

log_disable_color = s:option(Value, "log_disable_color", translate("Disable log color"))
log_disable_color:depends("enable_logging", "1")
log_disable_color.enabled = "true"
log_disable_color.disabled = "false"
log_disable_color.default = "1"

log_disable_timestamp = s:option(Value, "log_disable_timestamp", translate("Log disable timestamp"))
log_disable_timestamp:depends("enable_logging", "1")
log_disable_timestamp.enabled = "true"
log_disable_timestamp.disabled = "false"
log_disable_timestamp.default = "0"

-- [[ Cert ]]--
vless_grpc_inbound_cert_key = s:option(Flag, "vless_grpc_inbound_cert_key", translate("Self-signed Certificate"))
vless_grpc_inbound_cert_key.default = "0"
vless_grpc_inbound_cert_key.rmempty = true
vless_grpc_inbound_cert_key.description = translate("If you have a self-signed certificate,please check the box")

vless_grpc_inbound_cert_key = s:option(DummyValue, "upload", translate("Upload"))
vless_grpc_inbound_cert_key.template = "v2raya/v2raya_certupload"
vless_grpc_inbound_cert_key:depends("vless_grpc_inbound_cert_key", 1)

cert_dir = "/etc/v2raya/"
local path

luci.http.setfilehandler(function(meta, chunk, eof)
	if not fd then
		if (not meta) or (not meta.name) or (not meta.file) then
			return
		end
		fd = nixio.open(cert_dir .. meta.file, "w")
		if not fd then
			path = translate("Create upload file error.")
			return
		end
	end
	if chunk and fd then
		fd:write(chunk)
	end
	if eof and fd then
		fd:close()
		fd = nil
		path = '/etc/v2raya/' .. meta.file .. ''
	end
end)
if luci.http.formvalue("upload") then
	local f = luci.http.formvalue("ulfile")
	if #f <= 0 then
		path = translate("No specify upload file.")
	end
end

vless_grpc_inbound_cert_key = s:option(Value, "certpath", translate("Current Certificate Path"))
vless_grpc_inbound_cert_key.description = translate("Please confirm the current certificate path")
vless_grpc_inbound_cert_key:depends("vless_grpc_inbound_cert_key", 1)
vless_grpc_inbound_cert_key:value("crt",translate("etc/v2raya/grpc_certificate.crt"))
vless_grpc_inbound_cert_key:value("key",translate("/etc/v2raya/grpc_private.key"))

o.inputstyle = "reload"
    SYS.exec("/etc/init.d/v2raya restart >/dev/null 2>&1 &")


return m
