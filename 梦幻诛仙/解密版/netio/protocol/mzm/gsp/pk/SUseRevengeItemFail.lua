local SUseRevengeItemFail = class("SUseRevengeItemFail")
SUseRevengeItemFail.TYPEID = 12619797
SUseRevengeItemFail.DEPLETED = 1
SUseRevengeItemFail.PK_NOT_ENABLED = 2
SUseRevengeItemFail.TARGET_NOT_ONLINE = 3
SUseRevengeItemFail.TARGET_IN_SAFE_MAP = 4
function SUseRevengeItemFail:ctor(retcode)
  self.id = 12619797
  self.retcode = retcode or nil
end
function SUseRevengeItemFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SUseRevengeItemFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SUseRevengeItemFail:sizepolicy(size)
  return size <= 65535
end
return SUseRevengeItemFail
