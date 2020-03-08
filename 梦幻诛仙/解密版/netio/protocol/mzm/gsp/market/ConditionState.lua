local OctetsStream = require("netio.OctetsStream")
local ConditionState = class("ConditionState")
ConditionState.IN_PUBLIC = 0
ConditionState.IN_SELL = 1
ConditionState.NONE = 2
function ConditionState:ctor()
end
function ConditionState:marshal(os)
end
function ConditionState:unmarshal(os)
end
return ConditionState
