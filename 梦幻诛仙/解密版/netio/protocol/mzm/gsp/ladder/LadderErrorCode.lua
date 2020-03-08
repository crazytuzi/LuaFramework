local OctetsStream = require("netio.OctetsStream")
local LadderErrorCode = class("LadderErrorCode")
LadderErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
LadderErrorCode.ROLE_STATUS_ERROR = -2
LadderErrorCode.PARAM_ERROR = -3
LadderErrorCode.CHECK_NPC_SERVICE_ERROR = -4
LadderErrorCode.DB_ERROR = -5
LadderErrorCode.ALREADY_AWARDED = 1
function LadderErrorCode:ctor()
end
function LadderErrorCode:marshal(os)
end
function LadderErrorCode:unmarshal(os)
end
return LadderErrorCode
