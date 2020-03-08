local SAttendAxeActivityFail = class("SAttendAxeActivityFail")
SAttendAxeActivityFail.TYPEID = 12614914
SAttendAxeActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendAxeActivityFail.ROLE_STATUS_ERROR = -2
SAttendAxeActivityFail.PARAM_ERROR = -3
SAttendAxeActivityFail.YUAN_BAO_NUM_ERROR = -4
SAttendAxeActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendAxeActivityFail.ITEM_NOT_ENOUGH = 2
SAttendAxeActivityFail.YUANBAO_NOT_ENOUGH = 3
SAttendAxeActivityFail.ADD_LOTTERY_FAIL = 4
SAttendAxeActivityFail.GRID_NOT_ENOUGH = 5
SAttendAxeActivityFail.ACTIVITY_IS_LOCKED = 6
SAttendAxeActivityFail.GOLD_NOT_ENOUGH = 7
SAttendAxeActivityFail.SILVER_NOT_ENOUGH = 8
function SAttendAxeActivityFail:ctor(res)
  self.id = 12614914
  self.res = res or nil
end
function SAttendAxeActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendAxeActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendAxeActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendAxeActivityFail
