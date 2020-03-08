local SUnequipPetMarkFail = class("SUnequipPetMarkFail")
SUnequipPetMarkFail.TYPEID = 12628492
SUnequipPetMarkFail.ROLE_LEVEL_NOT_ENOUGH = -1
SUnequipPetMarkFail.PET_MARK_NOT_EXIST = -2
SUnequipPetMarkFail.PET_MARK_NOT_EQUIPED = -3
SUnequipPetMarkFail.UNEQUIP_FAILED = -4
function SUnequipPetMarkFail:ctor(error_code)
  self.id = 12628492
  self.error_code = error_code or nil
end
function SUnequipPetMarkFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SUnequipPetMarkFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SUnequipPetMarkFail:sizepolicy(size)
  return size <= 65535
end
return SUnequipPetMarkFail
