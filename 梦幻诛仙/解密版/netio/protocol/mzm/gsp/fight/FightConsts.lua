local OctetsStream = require("netio.OctetsStream")
local FightConsts = class("FightConsts")
FightConsts.AUTO_STATE__OPERATE = 0
FightConsts.AUTO_STATE__AUTO = 1
function FightConsts:ctor()
end
function FightConsts:marshal(os)
end
function FightConsts:unmarshal(os)
end
return FightConsts
