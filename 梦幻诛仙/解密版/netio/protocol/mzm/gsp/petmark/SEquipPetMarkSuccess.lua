local SEquipPetMarkSuccess = class("SEquipPetMarkSuccess")
SEquipPetMarkSuccess.TYPEID = 12628482
function SEquipPetMarkSuccess:ctor(pet_mark_id, pet_id)
  self.id = 12628482
  self.pet_mark_id = pet_mark_id or nil
  self.pet_id = pet_id or nil
end
function SEquipPetMarkSuccess:marshal(os)
  os:marshalInt64(self.pet_mark_id)
  os:marshalInt64(self.pet_id)
end
function SEquipPetMarkSuccess:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  self.pet_id = os:unmarshalInt64()
end
function SEquipPetMarkSuccess:sizepolicy(size)
  return size <= 65535
end
return SEquipPetMarkSuccess
