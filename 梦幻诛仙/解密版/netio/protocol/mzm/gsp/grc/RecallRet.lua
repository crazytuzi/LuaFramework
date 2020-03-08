local OctetsStream = require("netio.OctetsStream")
local RecallRet = class("RecallRet")
RecallRet.ERROR_SYSTEM = 1
RecallRet.ERROR_USERID = 2
RecallRet.ERROR_CFG = 3
RecallRet.ERROR_FUN_NOT_OPEN = 4
RecallRet.ERROR_STATUS = 5
function RecallRet:ctor()
end
function RecallRet:marshal(os)
end
function RecallRet:unmarshal(os)
end
return RecallRet
