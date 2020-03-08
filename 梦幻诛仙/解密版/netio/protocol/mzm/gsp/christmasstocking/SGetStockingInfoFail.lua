local SGetStockingInfoFail = class("SGetStockingInfoFail")
SGetStockingInfoFail.TYPEID = 12629516
SGetStockingInfoFail.CAN_NOT_JOIN_ACTIVITY = -1
SGetStockingInfoFail.TARGET_ROLE_NOT_JOIN_ACTIVITY = -2
SGetStockingInfoFail.NOT_IN_HOMELAND_OF_TARGET_ROLE = -3
SGetStockingInfoFail.TARGET_ROLE_NOT_EXIST = -4
function SGetStockingInfoFail:ctor(error_code)
  self.id = 12629516
  self.error_code = error_code or nil
end
function SGetStockingInfoFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SGetStockingInfoFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SGetStockingInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetStockingInfoFail
