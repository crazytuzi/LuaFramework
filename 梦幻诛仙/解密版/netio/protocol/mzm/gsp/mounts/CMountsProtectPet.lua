local CMountsProtectPet = class("CMountsProtectPet")
CMountsProtectPet.TYPEID = 12606227
function CMountsProtectPet:ctor(cell_id, protect_index, pet_id)
  self.id = 12606227
  self.cell_id = cell_id or nil
  self.protect_index = protect_index or nil
  self.pet_id = pet_id or nil
end
function CMountsProtectPet:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt32(self.protect_index)
  os:marshalInt64(self.pet_id)
end
function CMountsProtectPet:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.protect_index = os:unmarshalInt32()
  self.pet_id = os:unmarshalInt64()
end
function CMountsProtectPet:sizepolicy(size)
  return size <= 65535
end
return CMountsProtectPet
