local CEquipPetMarkReq = class("CEquipPetMarkReq")
CEquipPetMarkReq.TYPEID = 12628491
function CEquipPetMarkReq:ctor(pet_mark_id, pet_id)
  self.id = 12628491
  self.pet_mark_id = pet_mark_id or nil
  self.pet_id = pet_id or nil
end
function CEquipPetMarkReq:marshal(os)
  os:marshalInt64(self.pet_mark_id)
  os:marshalInt64(self.pet_id)
end
function CEquipPetMarkReq:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  self.pet_id = os:unmarshalInt64()
end
function CEquipPetMarkReq:sizepolicy(size)
  return size <= 65535
end
return CEquipPetMarkReq
