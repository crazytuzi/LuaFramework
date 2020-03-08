local OctetsStream = require("netio.OctetsStream")
local AwardState = class("AwardState")
AwardState.NO_AWRAD = 0
AwardState.NOT_SEND_AWARD = 1
AwardState.ALREADY_SEND_AWARD = 2
function AwardState:ctor()
end
function AwardState:marshal(os)
end
function AwardState:unmarshal(os)
end
return AwardState
