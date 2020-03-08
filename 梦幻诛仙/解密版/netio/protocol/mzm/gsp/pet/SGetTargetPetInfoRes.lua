local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local SGetTargetPetInfoRes = class("SGetTargetPetInfoRes")
SGetTargetPetInfoRes.TYPEID = 12590636
function SGetTargetPetInfoRes:ctor(petInfo)
  self.id = 12590636
  self.petInfo = petInfo or PetInfo.new()
end
function SGetTargetPetInfoRes:marshal(os)
  self.petInfo:marshal(os)
end
function SGetTargetPetInfoRes:unmarshal(os)
  self.petInfo = PetInfo.new()
  self.petInfo:unmarshal(os)
end
function SGetTargetPetInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetTargetPetInfoRes
