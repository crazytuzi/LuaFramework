local OctetsStream = require("netio.OctetsStream")
local RoundRobinRoundStage = class("RoundRobinRoundStage")
RoundRobinRoundStage.STAGE_NOT_START = -1
RoundRobinRoundStage.STAGE_PREPARE = 0
RoundRobinRoundStage.STAGE_FIGHT = 1
RoundRobinRoundStage.STAGE_END = 2
function RoundRobinRoundStage:ctor()
end
function RoundRobinRoundStage:marshal(os)
end
function RoundRobinRoundStage:unmarshal(os)
end
return RoundRobinRoundStage
