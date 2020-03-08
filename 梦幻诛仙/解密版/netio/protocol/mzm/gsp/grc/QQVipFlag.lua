local OctetsStream = require("netio.OctetsStream")
local QQVipFlag = class("QQVipFlag")
QQVipFlag.VIP_NORMAL = 1
QQVipFlag.VIP_QQ_LEVEL = 2
QQVipFlag.VIP_BLUE = 4
QQVipFlag.VIP_RED = 8
QQVipFlag.VIP_SUPER = 16
QQVipFlag.VIP_XINYUE = 64
QQVipFlag.VIP_YELLOW = 128
QQVipFlag.VIP_ANIMIC = 256
function QQVipFlag:ctor()
end
function QQVipFlag:marshal(os)
end
function QQVipFlag:unmarshal(os)
end
return QQVipFlag
