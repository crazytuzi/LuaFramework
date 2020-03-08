local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local SSyncAddPet = class("SSyncAddPet")
SSyncAddPet.TYPEID = 12590637
function SSyncAddPet:ctor(petInfo)
  self.id = 12590637
  self.petInfo = petInfo or PetInfo.new()
end
function SSyncAddPet:marshal(os)
  self.petInfo:marshal(os)
end
function SSyncAddPet:unmarshal(os)
  self.petInfo = PetInfo.new()
  self.petInfo:unmarshal(os)
end
function SSyncAddPet:sizepolicy(size)
  return size <= 65535
end
return SSyncAddPet
