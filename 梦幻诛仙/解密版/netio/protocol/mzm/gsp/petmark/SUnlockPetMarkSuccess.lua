local PetMarkInfo = require("netio.protocol.mzm.gsp.petmark.PetMarkInfo")
local SUnlockPetMarkSuccess = class("SUnlockPetMarkSuccess")
SUnlockPetMarkSuccess.TYPEID = 12628487
function SUnlockPetMarkSuccess:ctor(pet_mark_id, pet_mark_info)
  self.id = 12628487
  self.pet_mark_id = pet_mark_id or nil
  self.pet_mark_info = pet_mark_info or PetMarkInfo.new()
end
function SUnlockPetMarkSuccess:marshal(os)
  os:marshalInt64(self.pet_mark_id)
  self.pet_mark_info:marshal(os)
end
function SUnlockPetMarkSuccess:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  self.pet_mark_info = PetMarkInfo.new()
  self.pet_mark_info:unmarshal(os)
end
function SUnlockPetMarkSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnlockPetMarkSuccess
