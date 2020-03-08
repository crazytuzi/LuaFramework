local SUseCardFail = class("SUseCardFail")
SUseCardFail.TYPEID = 12624388
SUseCardFail.ROLE_LEVEL_NOT_ENOUGH = -1
SUseCardFail.CARD_NOT_EXIST = -2
SUseCardFail.ESSENCE_NOT_ENOUGH = -3
SUseCardFail.OVERLAY_COUNT_NOT_ENOUGH = -4
function SUseCardFail:ctor(error_code)
  self.id = 12624388
  self.error_code = error_code or nil
end
function SUseCardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SUseCardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SUseCardFail:sizepolicy(size)
  return size <= 65535
end
return SUseCardFail
