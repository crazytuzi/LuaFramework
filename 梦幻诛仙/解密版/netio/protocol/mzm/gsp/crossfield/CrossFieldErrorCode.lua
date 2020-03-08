local OctetsStream = require("netio.OctetsStream")
local CrossFieldErrorCode = class("CrossFieldErrorCode")
CrossFieldErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
CrossFieldErrorCode.ROLE_STATUS_ERROR = -2
CrossFieldErrorCode.PARAM_ERROR = -3
CrossFieldErrorCode.CHECK_NPC_SERVICE_ERROR = -4
CrossFieldErrorCode.DB_ERROR = -5
CrossFieldErrorCode.CANNOT_JOIN_ACTIVITY = 1
CrossFieldErrorCode.IN_TEAM = 2
CrossFieldErrorCode.ALREADY_JOIN_MATCH = 3
CrossFieldErrorCode.UNKNOWM_ERROR = 4
CrossFieldErrorCode.IS_NOT_MATCHING = 5
CrossFieldErrorCode.IS_CANCELIND_MATCH = 6
CrossFieldErrorCode.FORBID_MATCH = 7
CrossFieldErrorCode.NO_ACTIVE_SEASON = 8
CrossFieldErrorCode.COMMUNICATION_ERROR = 9
CrossFieldErrorCode.ALREADY_AWARDED = 10
CrossFieldErrorCode.AWARD_FAIL = 11
function CrossFieldErrorCode:ctor()
end
function CrossFieldErrorCode:marshal(os)
end
function CrossFieldErrorCode:unmarshal(os)
end
return CrossFieldErrorCode
