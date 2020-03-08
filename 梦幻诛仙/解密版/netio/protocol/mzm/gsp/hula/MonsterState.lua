local OctetsStream = require("netio.OctetsStream")
local MonsterState = class("MonsterState")
MonsterState.STATE_ALIVE = 1
MonsterState.STATE_DIE = 2
MonsterState.STATE_FIGHTING = 4
function MonsterState:ctor()
end
function MonsterState:marshal(os)
end
function MonsterState:unmarshal(os)
end
return MonsterState
