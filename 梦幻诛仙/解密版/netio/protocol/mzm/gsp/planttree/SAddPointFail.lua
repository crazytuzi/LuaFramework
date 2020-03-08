local SAddPointFail = class("SAddPointFail")
SAddPointFail.TYPEID = 12611594
SAddPointFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAddPointFail.ROLE_STATUS_ERROR = -2
SAddPointFail.PARAM_ERROR = -3
SAddPointFail.DB_ERROR = -4
SAddPointFail.CAN_NOT_JOIN_ACTIVITY = 1
SAddPointFail.ADD_POINT_TO_LIMIT = 2
SAddPointFail.ACTIVITY_POINT_FULL = 3
SAddPointFail.MONEY_NOT_MATCH = 4
SAddPointFail.MONEY_NOT_ENOUGH = 5
SAddPointFail.COST_MONEY_FAIL = 6
SAddPointFail.IN_SPECIAL_STATE = 7
SAddPointFail.DAILY_REWARD_POINT_TO_LIMIT = 8
SAddPointFail.NOT_ONLINE = 9
function SAddPointFail:ctor(res)
  self.id = 12611594
  self.res = res or nil
end
function SAddPointFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAddPointFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAddPointFail:sizepolicy(size)
  return size <= 65535
end
return SAddPointFail
