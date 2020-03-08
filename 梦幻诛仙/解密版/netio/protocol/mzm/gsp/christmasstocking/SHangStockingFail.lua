local SHangStockingFail = class("SHangStockingFail")
SHangStockingFail.TYPEID = 12629507
SHangStockingFail.CAN_NOT_JOIN_ACTIVITY = -1
SHangStockingFail.TARGET_ROLE_NOT_JOIN_ACTIVITY = -2
SHangStockingFail.NOT_IN_HOMELAND_OF_TARGET_ROLE = -3
SHangStockingFail.INVALID_POSITION = -4
SHangStockingFail.POSITION_NOT_EMPTY = -5
SHangStockingFail.ITEM_NOT_ENOUGH = -6
SHangStockingFail.REMAIN_HANG_ON_ONE_TREE_NUM_NOT_ENOUGH = -7
SHangStockingFail.REMAIN_ROLE_HANG_NUM_NOT_ENOUGH = -8
SHangStockingFail.TARGET_ROLE_NOT_EXIST = -9
SHangStockingFail.REMAIN_SELF_HANG_NUM_NOT_ENOUGH = -10
SHangStockingFail.REMAIN_OTHERS_HANG_NUM_NOT_ENOUGH = -11
SHangStockingFail.REMAIN_HANG_FOR_OTHERS_NUM_NOT_ENOUGH = -12
function SHangStockingFail:ctor(error_code)
  self.id = 12629507
  self.error_code = error_code or nil
end
function SHangStockingFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SHangStockingFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SHangStockingFail:sizepolicy(size)
  return size <= 65535
end
return SHangStockingFail
