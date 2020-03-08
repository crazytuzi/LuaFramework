local SCancelCardFail = class("SCancelCardFail")
SCancelCardFail.TYPEID = 12624401
SCancelCardFail.ROLE_LEVEL_NOT_ENOUGH = -1
SCancelCardFail.CARD_NOT_ACTIVATED = -2
function SCancelCardFail:ctor(error_code)
  self.id = 12624401
  self.error_code = error_code or nil
end
function SCancelCardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SCancelCardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SCancelCardFail:sizepolicy(size)
  return size <= 65535
end
return SCancelCardFail
