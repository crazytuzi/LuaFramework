local SUnlockPetMarkFail = class("SUnlockPetMarkFail")
SUnlockPetMarkFail.TYPEID = 12628511
SUnlockPetMarkFail.ROLE_LEVEL_NOT_ENOUGH = -1
SUnlockPetMarkFail.ITEM_NOT_EXIST = -2
SUnlockPetMarkFail.ITEM_NOT_PET_MARK_ITEM = -3
SUnlockPetMarkFail.ITEM_NOT_ENOUGH = -4
SUnlockPetMarkFail.PET_MARK_IS_GENERAL = -5
SUnlockPetMarkFail.PET_MARK_CARRY_NUM_NOT_ENOUGH = -6
function SUnlockPetMarkFail:ctor(error_code)
  self.id = 12628511
  self.error_code = error_code or nil
end
function SUnlockPetMarkFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SUnlockPetMarkFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SUnlockPetMarkFail:sizepolicy(size)
  return size <= 65535
end
return SUnlockPetMarkFail
