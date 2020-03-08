local OctetsStream = require("netio.OctetsStream")
local CrossBattleBetErrorCode = class("CrossBattleBetErrorCode")
CrossBattleBetErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
CrossBattleBetErrorCode.ROLE_STATUS_ERROR = -2
CrossBattleBetErrorCode.PARAM_ERROR = -3
CrossBattleBetErrorCode.CHECK_NPC_SERVICE_ERROR = -4
CrossBattleBetErrorCode.DB_ERROR = -5
CrossBattleBetErrorCode.ACTIVITY_NOT_OPEN = 1
CrossBattleBetErrorCode.ACTIVITY_STAGE_ERROR = 2
CrossBattleBetErrorCode.FIGHT_END = 3
CrossBattleBetErrorCode.FIGHT_NOT_EXIST = 4
CrossBattleBetErrorCode.FIGHT_NOT_END = 5
CrossBattleBetErrorCode.NOT_BET = 6
CrossBattleBetErrorCode.HAS_GOT_MAIL = 7
CrossBattleBetErrorCode.SEND_MAIL_FAIL = 8
CrossBattleBetErrorCode.STAGE_NOT_END = 9
CrossBattleBetErrorCode.COMMUNICATION_ERROR = 10
CrossBattleBetErrorCode.GET_STAGE_DATA_FAIL = 11
CrossBattleBetErrorCode.GET_STAGE_BET_DATA_FAIL = 12
CrossBattleBetErrorCode.ALREADY_AWARDED = 13
function CrossBattleBetErrorCode:ctor()
end
function CrossBattleBetErrorCode:marshal(os)
end
function CrossBattleBetErrorCode:unmarshal(os)
end
return CrossBattleBetErrorCode
