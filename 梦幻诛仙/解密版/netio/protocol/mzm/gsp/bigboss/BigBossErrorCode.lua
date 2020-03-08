local OctetsStream = require("netio.OctetsStream")
local BigBossErrorCode = class("BigBossErrorCode")
BigBossErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
BigBossErrorCode.ROLE_STATUS_ERROR = -2
BigBossErrorCode.PARAM_ERROR = -3
BigBossErrorCode.CHECK_NPC_SERVICE_ERROR = -4
BigBossErrorCode.DB_ERROR = -5
BigBossErrorCode.ACTIVITY_START_TIMESTAMP_ERROR = -6
BigBossErrorCode.ALREADY_AWARDED = -7
BigBossErrorCode.COMMUNICATION_ERROR = 1
function BigBossErrorCode:ctor()
end
function BigBossErrorCode:marshal(os)
end
function BigBossErrorCode:unmarshal(os)
end
return BigBossErrorCode
