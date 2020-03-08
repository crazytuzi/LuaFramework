local SSetCardVisibleFail = class("SSetCardVisibleFail")
SSetCardVisibleFail.TYPEID = 12624398
SSetCardVisibleFail.ROLE_LEVEL_NOT_ENOUGH = -1
SSetCardVisibleFail.CARD_NOT_ACTIVATED = -2
SSetCardVisibleFail.CARD_ALREADY_VISIBLE = -3
function SSetCardVisibleFail:ctor(error_code)
  self.id = 12624398
  self.error_code = error_code or nil
end
function SSetCardVisibleFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SSetCardVisibleFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SSetCardVisibleFail:sizepolicy(size)
  return size <= 65535
end
return SSetCardVisibleFail
