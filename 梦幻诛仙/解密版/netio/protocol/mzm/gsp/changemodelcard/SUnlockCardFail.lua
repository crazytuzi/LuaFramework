local SUnlockCardFail = class("SUnlockCardFail")
SUnlockCardFail.TYPEID = 12624386
SUnlockCardFail.ROLE_LEVEL_NOT_ENOUGH = -1
SUnlockCardFail.ITEM_NOT_EXIST = -2
SUnlockCardFail.ITEM_NOT_CARD_ITEM = -3
SUnlockCardFail.ITEM_NOT_ENOUGH = -4
function SUnlockCardFail:ctor(error_code)
  self.id = 12624386
  self.error_code = error_code or nil
end
function SUnlockCardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SUnlockCardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SUnlockCardFail:sizepolicy(size)
  return size <= 65535
end
return SUnlockCardFail
