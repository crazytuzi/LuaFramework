local SUseRevengeItemTransferFail = class("SUseRevengeItemTransferFail")
SUseRevengeItemTransferFail.TYPEID = 12619795
SUseRevengeItemTransferFail.CONTEXT_NOT_EXISTS = 1
function SUseRevengeItemTransferFail:ctor(retcode)
  self.id = 12619795
  self.retcode = retcode or nil
end
function SUseRevengeItemTransferFail:marshal(os)
  os:marshalInt32(self.retcode)
end
function SUseRevengeItemTransferFail:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SUseRevengeItemTransferFail:sizepolicy(size)
  return size <= 65535
end
return SUseRevengeItemTransferFail
