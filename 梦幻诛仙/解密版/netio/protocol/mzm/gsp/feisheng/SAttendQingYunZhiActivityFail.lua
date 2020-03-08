local SAttendQingYunZhiActivityFail = class("SAttendQingYunZhiActivityFail")
SAttendQingYunZhiActivityFail.TYPEID = 12614149
SAttendQingYunZhiActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendQingYunZhiActivityFail.ROLE_STATUS_ERROR = -2
SAttendQingYunZhiActivityFail.PARAM_ERROR = -3
SAttendQingYunZhiActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendQingYunZhiActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendQingYunZhiActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendQingYunZhiActivityFail.QING_YUN_ZHI_NOT_COMPLETE = 2
SAttendQingYunZhiActivityFail.AWARD_FAIL = 3
function SAttendQingYunZhiActivityFail:ctor(res)
  self.id = 12614149
  self.res = res or nil
end
function SAttendQingYunZhiActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendQingYunZhiActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendQingYunZhiActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendQingYunZhiActivityFail
