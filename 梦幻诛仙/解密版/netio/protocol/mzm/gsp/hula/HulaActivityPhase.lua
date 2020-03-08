local OctetsStream = require("netio.OctetsStream")
local HulaActivityPhase = class("HulaActivityPhase")
HulaActivityPhase.STAGE_PREPARE = 0
HulaActivityPhase.STAGE_DOUDOU_COMEONT = 1
HulaActivityPhase.STAGE_DOUDOU_DELETE = 2
function HulaActivityPhase:ctor()
end
function HulaActivityPhase:marshal(os)
end
function HulaActivityPhase:unmarshal(os)
end
return HulaActivityPhase
