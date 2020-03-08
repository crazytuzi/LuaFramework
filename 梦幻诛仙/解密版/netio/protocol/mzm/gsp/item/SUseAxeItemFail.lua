local SUseAxeItemFail = class("SUseAxeItemFail")
SUseAxeItemFail.TYPEID = 12584866
SUseAxeItemFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SUseAxeItemFail.ROLE_STATUS_ERROR = -2
SUseAxeItemFail.PARAM_ERROR = -3
SUseAxeItemFail.NOT_AXE_ITEM = 1
SUseAxeItemFail.NUM_NOT_ENOUGH = 2
SUseAxeItemFail.AWARD_FAIL = 3
function SUseAxeItemFail:ctor(res)
  self.id = 12584866
  self.res = res or nil
end
function SUseAxeItemFail:marshal(os)
  os:marshalInt32(self.res)
end
function SUseAxeItemFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SUseAxeItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseAxeItemFail
