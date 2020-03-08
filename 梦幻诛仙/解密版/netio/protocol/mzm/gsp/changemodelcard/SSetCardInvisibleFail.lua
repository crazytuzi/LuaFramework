local SSetCardInvisibleFail = class("SSetCardInvisibleFail")
SSetCardInvisibleFail.TYPEID = 12624408
SSetCardInvisibleFail.ROLE_LEVEL_NOT_ENOUGH = -1
SSetCardInvisibleFail.CARD_NOT_ACTIVATED = -2
SSetCardInvisibleFail.CARD_ALREADY_INVISIBLE = -3
function SSetCardInvisibleFail:ctor(error_code)
  self.id = 12624408
  self.error_code = error_code or nil
end
function SSetCardInvisibleFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SSetCardInvisibleFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SSetCardInvisibleFail:sizepolicy(size)
  return size <= 65535
end
return SSetCardInvisibleFail
