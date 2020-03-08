local OctetsStream = require("netio.OctetsStream")
local PetAptConsts = class("PetAptConsts")
PetAptConsts.HP_APT = 0
PetAptConsts.PHYATK_APT = 1
PetAptConsts.PHYDEF_APT = 2
PetAptConsts.MAGATK_APT = 3
PetAptConsts.MAGDEF_APT = 4
PetAptConsts.SPEED_APT = 5
function PetAptConsts:ctor()
end
function PetAptConsts:marshal(os)
end
function PetAptConsts:unmarshal(os)
end
return PetAptConsts
