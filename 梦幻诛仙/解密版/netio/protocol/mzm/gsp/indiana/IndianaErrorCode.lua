local OctetsStream = require("netio.OctetsStream")
local IndianaErrorCode = class("IndianaErrorCode")
IndianaErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
IndianaErrorCode.ROLE_STATUS_ERROR = -2
IndianaErrorCode.PARAM_ERROR = -3
IndianaErrorCode.CHECK_NPC_SERVICE_ERROR = -4
IndianaErrorCode.DB_ERROR = -5
IndianaErrorCode.ALREADY_GET_AWARD_NUMBER = -6
IndianaErrorCode.AWARD_STATE_ERROR = -7
IndianaErrorCode.BRD_NUMBERS_EMPTY = -8
IndianaErrorCode.CANNOT_JOIN_ACTIVITY = 1
IndianaErrorCode.NOT_CURRENT_TURN = 2
IndianaErrorCode.ALREADY_ATTENDED = 3
IndianaErrorCode.ITEM_NUM_NOT_MATCH = 4
IndianaErrorCode.ITEM_PRICE_ERROR = 5
IndianaErrorCode.YUANBAO_NUM_NOT_MATCH = 6
IndianaErrorCode.COST_ITEM_FAIL = 7
IndianaErrorCode.COST_MONEY_FAIL = 8
IndianaErrorCode.SEND_MAIL_FAIL = 9
IndianaErrorCode.COMMUNICATION_ERROR = 10
IndianaErrorCode.GRC_TIMEOUT = 11
IndianaErrorCode.GRC_FAIL = 12
IndianaErrorCode.TURN_NOT_END = 13
IndianaErrorCode.NOT_GOT_AWARD_NUMBER = 14
function IndianaErrorCode:ctor()
end
function IndianaErrorCode:marshal(os)
end
function IndianaErrorCode:unmarshal(os)
end
return IndianaErrorCode
