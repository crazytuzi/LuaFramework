local OctetsStream = require("netio.OctetsStream")
local AllLottoErrorCode = class("AllLottoErrorCode")
AllLottoErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
AllLottoErrorCode.ROLE_STATUS_ERROR = -2
AllLottoErrorCode.PARAM_ERROR = -3
AllLottoErrorCode.CHECK_NPC_SERVICE_ERROR = -4
AllLottoErrorCode.DB_ERROR = -5
AllLottoErrorCode.SERVER_LEVEL_NOT_ENOUGH = -6
AllLottoErrorCode.NO_ONLINE_ROLE = -7
AllLottoErrorCode.NO_CANDIDATE = -8
AllLottoErrorCode.ALREADY_GOT_AWARD_ROLE_INFO = -9
AllLottoErrorCode.AWARD_STATE_ERROR = -10
AllLottoErrorCode.CANNOT_JOIN_ACTIVITY = 1
AllLottoErrorCode.NOT_IN_AWARD_TIME = 2
AllLottoErrorCode.ALREADY_GOT_AWARD = 3
AllLottoErrorCode.AWARD_FAIL = 4
function AllLottoErrorCode:ctor()
end
function AllLottoErrorCode:marshal(os)
end
function AllLottoErrorCode:unmarshal(os)
end
return AllLottoErrorCode
