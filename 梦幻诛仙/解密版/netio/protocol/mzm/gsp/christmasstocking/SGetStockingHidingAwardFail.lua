local SGetStockingHidingAwardFail = class("SGetStockingHidingAwardFail")
SGetStockingHidingAwardFail.TYPEID = 12629518
SGetStockingHidingAwardFail.CAN_NOT_JOIN_ACTIVITY = -1
SGetStockingHidingAwardFail.NOT_IN_SELF_HOMELAND = -2
SGetStockingHidingAwardFail.REMAIN_GET_AWARD_NUM_NOT_ENOUGH = -3
function SGetStockingHidingAwardFail:ctor(error_code)
  self.id = 12629518
  self.error_code = error_code or nil
end
function SGetStockingHidingAwardFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SGetStockingHidingAwardFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SGetStockingHidingAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetStockingHidingAwardFail
