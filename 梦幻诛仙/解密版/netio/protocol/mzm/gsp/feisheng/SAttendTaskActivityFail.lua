local SAttendTaskActivityFail = class("SAttendTaskActivityFail")
SAttendTaskActivityFail.TYPEID = 12614171
SAttendTaskActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendTaskActivityFail.ROLE_STATUS_ERROR = -2
SAttendTaskActivityFail.PARAM_ERROR = -3
SAttendTaskActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendTaskActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendTaskActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendTaskActivityFail.ACTIVE_TASK_GRAPH_FAIL = 2
SAttendTaskActivityFail.AWARD_FAIL = 3
function SAttendTaskActivityFail:ctor(res)
  self.id = 12614171
  self.res = res or nil
end
function SAttendTaskActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendTaskActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendTaskActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendTaskActivityFail
