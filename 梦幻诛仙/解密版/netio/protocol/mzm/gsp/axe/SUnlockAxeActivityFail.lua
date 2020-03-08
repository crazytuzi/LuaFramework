local SUnlockAxeActivityFail = class("SUnlockAxeActivityFail")
SUnlockAxeActivityFail.TYPEID = 12614917
SUnlockAxeActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SUnlockAxeActivityFail.ROLE_STATUS_ERROR = -2
SUnlockAxeActivityFail.PARAM_ERROR = -3
SUnlockAxeActivityFail.YUAN_BAO_NUM_ERROR = -4
SUnlockAxeActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SUnlockAxeActivityFail.ACTIVITY_IS_NOT_LOCKED = 2
SUnlockAxeActivityFail.YUANBAO_NOT_ENOUGH = 3
SUnlockAxeActivityFail.GOLD_NOT_ENOUGH = 4
SUnlockAxeActivityFail.SILVER_NOT_ENOUGH = 5
function SUnlockAxeActivityFail:ctor(res)
  self.id = 12614917
  self.res = res or nil
end
function SUnlockAxeActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SUnlockAxeActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SUnlockAxeActivityFail:sizepolicy(size)
  return size <= 65535
end
return SUnlockAxeActivityFail
