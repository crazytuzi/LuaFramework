local OctetsStream = require("netio.OctetsStream")
local SwitchType = class("SwitchType")
SwitchType.GUA_JI = 1
SwitchType.ZHEN_YAO = 2
function SwitchType:ctor()
end
function SwitchType:marshal(os)
end
function SwitchType:unmarshal(os)
end
return SwitchType
