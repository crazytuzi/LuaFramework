local OctetsStream = require("netio.OctetsStream")
local MassExpRet = class("MassExpRet")
MassExpRet.ERROR_SYSTEM = 1
MassExpRet.ERROR_STATUS = 2
MassExpRet.ERROR_CFG = 3
MassExpRet.ERROR_NOT_END = 4
function MassExpRet:ctor()
end
function MassExpRet:marshal(os)
end
function MassExpRet:unmarshal(os)
end
return MassExpRet
