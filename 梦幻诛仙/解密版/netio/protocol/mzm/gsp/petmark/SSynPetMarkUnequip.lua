local SSynPetMarkUnequip = class("SSynPetMarkUnequip")
SSynPetMarkUnequip.TYPEID = 12628513
function SSynPetMarkUnequip:ctor(pet_mark_id, pet_id)
  self.id = 12628513
  self.pet_mark_id = pet_mark_id or nil
  self.pet_id = pet_id or nil
end
function SSynPetMarkUnequip:marshal(os)
  os:marshalInt64(self.pet_mark_id)
  os:marshalInt64(self.pet_id)
end
function SSynPetMarkUnequip:unmarshal(os)
  self.pet_mark_id = os:unmarshalInt64()
  self.pet_id = os:unmarshalInt64()
end
function SSynPetMarkUnequip:sizepolicy(size)
  return size <= 65535
end
return SSynPetMarkUnequip
