local PetArenaInfo = require("netio.protocol.mzm.gsp.petarena.PetArenaInfo")
local SGetPetArenaInfoSuccess = class("SGetPetArenaInfoSuccess")
SGetPetArenaInfoSuccess.TYPEID = 12628231
function SGetPetArenaInfoSuccess:ctor(pet_arena_info)
  self.id = 12628231
  self.pet_arena_info = pet_arena_info or PetArenaInfo.new()
end
function SGetPetArenaInfoSuccess:marshal(os)
  self.pet_arena_info:marshal(os)
end
function SGetPetArenaInfoSuccess:unmarshal(os)
  self.pet_arena_info = PetArenaInfo.new()
  self.pet_arena_info:unmarshal(os)
end
function SGetPetArenaInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetPetArenaInfoSuccess
