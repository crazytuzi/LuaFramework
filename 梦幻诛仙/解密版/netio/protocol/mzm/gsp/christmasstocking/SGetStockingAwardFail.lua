local SGetStockingAwardFail = class("SGetStockingAwardFail")
SGetStockingAwardFail.TYPEID = 12629506
SGetStockingAwardFail.CAN_NOT_JOIN_ACTIVITY = -1
SGetStockingAwardFail.NOT_IN_SELF_HOMELAND = -2
SGetStockingAwardFail.INVALID_POSITION = -3
SGetStockingAwardFail.POSITION_NO_AWARD = -4
function SGetStockingAwardFail:ctor(error_code)
  self.id = 12629506
  self.error_code = error_code or nil
end
function SGetStockingAwardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SGetStockingAwardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SGetStockingAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetStockingAwardFail
