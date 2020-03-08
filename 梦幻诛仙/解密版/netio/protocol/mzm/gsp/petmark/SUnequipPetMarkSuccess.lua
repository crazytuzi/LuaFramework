local SUnequipPetMarkSuccess = class("SUnequipPetMarkSuccess")
SUnequipPetMarkSuccess.TYPEID = 12628496
function SUnequipPetMarkSuccess:ctor(pet_mark_id, pet_id)
  self.id = 12628496
  self.pet_mark_id = pet_mark_id or nil
  self.pet_id = pet_id or nil
end
function SUnequipPetMarkSuccess:marshal(os)
  os:marshalInt64(self.pet_mark_id)
  os:marshalInt64(self.pet_id)
end
function SUnequipPetMarkSuccess:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  self.pet_id = os:unmarshalInt64()
end
function SUnequipPetMarkSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnequipPetMarkSuccess
