local SEquipPetMarkFail = class("SEquipPetMarkFail")
SEquipPetMarkFail.TYPEID = 12628502
SEquipPetMarkFail.ROLE_LEVEL_NOT_ENOUGH = -1
SEquipPetMarkFail.PET_MARK_NOT_EXIST = -2
SEquipPetMarkFail.PET_NOT_EXIST = -3
SEquipPetMarkFail.THIS_PET_ALREADY_EQUIPED_THIS_MARK = -4
SEquipPetMarkFail.EQUIP_FAILED = -5
function SEquipPetMarkFail:ctor(error_code)
  self.id = 12628502
  self.error_code = error_code or nil
end
function SEquipPetMarkFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SEquipPetMarkFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SEquipPetMarkFail:sizepolicy(size)
  return size <= 65535
end
return SEquipPetMarkFail
