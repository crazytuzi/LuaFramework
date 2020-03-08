local OctetsStream = require("netio.OctetsStream")
local CrossBattleOwnErrorCode = class("CrossBattleOwnErrorCode")
CrossBattleOwnErrorCode.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
CrossBattleOwnErrorCode.CORPS_ALREADY_REGISTER = 1
CrossBattleOwnErrorCode.CORPS_NOT_REGISTER = 2
CrossBattleOwnErrorCode.CORPS_MEMBER_NUM_SATISFIED = 3
CrossBattleOwnErrorCode.ACTIVITY_NOT_OPEN = 4
CrossBattleOwnErrorCode.ACTIVITY_STAGE_ERROR = 5
CrossBattleOwnErrorCode.ROUND_ROBIN_ROUND_END = 6
CrossBattleOwnErrorCode.ROUND_ROBIN_ROUND_INDEX_ERROR = 7
CrossBattleOwnErrorCode.ROUND_ROBIN_FIGHT_END = 8
CrossBattleOwnErrorCode.ROUND_ROBIN_FIGHT_NO_ATTEND_ROLE = 9
function CrossBattleOwnErrorCode:ctor()
end
function CrossBattleOwnErrorCode:marshal(os)
end
function CrossBattleOwnErrorCode:unmarshal(os)
end
return CrossBattleOwnErrorCode
