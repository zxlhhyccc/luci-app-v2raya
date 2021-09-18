-- Copyright 2008 Yanira <forum-2008@email.de>
-- Copyright 2020 KFERMercer <KFER.Mercer@gmail.com>
-- Licensed to the public under the Apache License 2.0.

m = Map("v2raya")
m.title = translate("v2rayA")
m.description = translate("简易的 v2rayA 开关")

m:section(SimpleSection).template = "v2raya/v2raya_status"

s = m:section(TypedSection,"v2raya")
s.addremove = false
s.anonymous = true

o = s:option(Flag, "enabled", translate("启用"))
o.rmempty = false

o.description = translate("启用后，浏览器输入: 后台IP+:2017，例如:192.168.1.1:2017")
o.default = 0
o.rmempty = false

return m
