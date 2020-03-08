local OctetsStream = require("netio.OctetsStream")
local AwardState = class("AwardState")
AwardState.NOT_AWARDED = 0
AwardState.AWARDED = 1
AwardState.OTERT_SERVER = 2
function AwardState:ctor()
end
function AwardState:marshal(os)
end
function AwardState:unmarshal(os)
end
return AwardState
