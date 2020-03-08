local OctetsStream = require("netio.OctetsStream")
local GetKnockoutStageBetInfoReason = class("GetKnockoutStageBetInfoReason")
GetKnockoutStageBetInfoReason.REASON_GET_KNOCKOUT_STAGE_BET_INFO = 0
GetKnockoutStageBetInfoReason.REASON_SETTLE_ROLE_KNOCKOUT_STAGE_BET = 1
function GetKnockoutStageBetInfoReason:ctor()
end
function GetKnockoutStageBetInfoReason:marshal(os)
end
function GetKnockoutStageBetInfoReason:unmarshal(os)
end
return GetKnockoutStageBetInfoReason
