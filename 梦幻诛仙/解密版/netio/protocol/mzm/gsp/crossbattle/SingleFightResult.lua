local OctetsStream = require("netio.OctetsStream")
local SingleFightResult = class("SingleFightResult")
SingleFightResult.STATE_NOT_START = 0
SingleFightResult.FIGHT_WIN = 1
SingleFightResult.FIGHT_LOSE = 2
SingleFightResult.ABSTAIN_WIN = 3
SingleFightResult.ABSTAIN_LOSE = 4
SingleFightResult.BYE_WIN = 5
SingleFightResult.BYE = 6
SingleFightResult.IN_FIGHTING = 7
function SingleFightResult:ctor()
end
function SingleFightResult:marshal(os)
end
function SingleFightResult:unmarshal(os)
end
return SingleFightResult
