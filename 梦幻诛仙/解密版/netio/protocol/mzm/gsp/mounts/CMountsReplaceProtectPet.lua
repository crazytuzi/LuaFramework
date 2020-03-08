local CMountsReplaceProtectPet = class("CMountsReplaceProtectPet")
CMountsReplaceProtectPet.TYPEID = 12606247
function CMountsReplaceProtectPet:ctor(cell_id, protect_index, old_pet_id, now_pet_id)
  self.id = 12606247
  self.cell_id = cell_id or nil
  self.protect_index = protect_index or nil
  self.old_pet_id = old_pet_id or nil
  self.now_pet_id = now_pet_id or nil
end
function CMountsReplaceProtectPet:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt32(self.protect_index)
  os:marshalInt64(self.old_pet_id)
  os:marshalInt64(self.now_pet_id)
end
function CMountsReplaceProtectPet:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.protect_index = os:unmarshalInt32()
  self.old_pet_id = os:unmarshalInt64()
  self.now_pet_id = os:unmarshalInt64()
end
function CMountsReplaceProtectPet:sizepolicy(size)
  return size <= 65535
end
return CMountsReplaceProtectPet
