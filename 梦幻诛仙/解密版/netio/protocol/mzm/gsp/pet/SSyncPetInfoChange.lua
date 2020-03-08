local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local SSyncPetInfoChange = class("SSyncPetInfoChange")
SSyncPetInfoChange.TYPEID = 12590603
function SSyncPetInfoChange:ctor(petInfo)
  self.id = 12590603
  self.petInfo = petInfo or PetInfo.new()
end
function SSyncPetInfoChange:marshal(os)
  self.petInfo:marshal(os)
end
function SSyncPetInfoChange:unmarshal(os)
  self.petInfo = PetInfo.new()
  self.petInfo:unmarshal(os)
end
function SSyncPetInfoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncPetInfoChange
