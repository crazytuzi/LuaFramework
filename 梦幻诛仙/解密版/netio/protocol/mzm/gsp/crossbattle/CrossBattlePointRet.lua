local OctetsStream = require("netio.OctetsStream")
local CrossBattlePointRet = class("CrossBattlePointRet")
CrossBattlePointRet.ACTIVITY_NOT_OPEN = 1
CrossBattlePointRet.ACTIVITY_STAGE_ERROR = 2
CrossBattlePointRet.STATUS_CAN_NOT_DO_ACTION = 3
CrossBattlePointRet.ACTIVITY_NOT_CAN_JOIN = 4
CrossBattlePointRet.CORPS_NOT_EXIST = 5
CrossBattlePointRet.CORPS_PROMOTION_FAIL = 6
CrossBattlePointRet.CFG_NOT_EXIST = 7
CrossBattlePointRet.SYSTEM_ERROR = 8
function CrossBattlePointRet:ctor()
end
function CrossBattlePointRet:marshal(os)
end
function CrossBattlePointRet:unmarshal(os)
end
return CrossBattlePointRet
