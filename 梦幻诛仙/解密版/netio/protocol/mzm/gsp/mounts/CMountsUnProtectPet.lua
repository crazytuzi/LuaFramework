local CMountsUnProtectPet = class("CMountsUnProtectPet")
CMountsUnProtectPet.TYPEID = 12606237
function CMountsUnProtectPet:ctor(cell_id, protect_index, pet_id)
  self.id = 12606237
  self.cell_id = cell_id or nil
  self.protect_index = protect_index or nil
  self.pet_id = pet_id or nil
end
function CMountsUnProtectPet:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt32(self.protect_index)
  os:marshalInt64(self.pet_id)
end
function CMountsUnProtectPet:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.protect_index = os:unmarshalInt32()
  self.pet_id = os:unmarshalInt64()
end
function CMountsUnProtectPet:sizepolicy(size)
  return size <= 65535
end
return CMountsUnProtectPet
