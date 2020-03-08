local OctetsStream = require("netio.OctetsStream")
local QiLinMode = class("QiLinMode")
QiLinMode.RISK_MODE = 0
QiLinMode.ACCUMULATION_MODE = 1
function QiLinMode:ctor()
end
function QiLinMode:marshal(os)
end
function QiLinMode:unmarshal(os)
end
return QiLinMode
