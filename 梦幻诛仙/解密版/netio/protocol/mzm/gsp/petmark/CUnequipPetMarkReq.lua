local CUnequipPetMarkReq = class("CUnequipPetMarkReq")
CUnequipPetMarkReq.TYPEID = 12628488
function CUnequipPetMarkReq:ctor(pet_mark_id)
  self.id = 12628488
  self.pet_mark_id = pet_mark_id or nil
end
function CUnequipPetMarkReq:marshal(os)
  os:marshalInt64(self.pet_mark_id)
end
function CUnequipPetMarkReq:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
end
function CUnequipPetMarkReq:sizepolicy(size)
  return size <= 65535
end
return CUnequipPetMarkReq
