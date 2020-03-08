local OctetsStream = require("netio.OctetsStream")
local CalFightResult = class("CalFightResult")
CalFightResult.STATE_NOT_START = 0
CalFightResult.A_FIGHT_WIN = 1
CalFightResult.A_FIGHT_LOSE = 2
CalFightResult.A_ABSTAIN_WIN = 3
CalFightResult.A_ABSTAIN_LOSE = 4
CalFightResult.A_BYE_WIN = 5
CalFightResult.B_BYE_WIN = 6
CalFightResult.ALL_ABSTAIN = 7
CalFightResult.ALL_BYE = 8
function CalFightResult:ctor()
end
function CalFightResult:marshal(os)
end
function CalFightResult:unmarshal(os)
end
return CalFightResult
