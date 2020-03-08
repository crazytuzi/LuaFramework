local SAttendFightActivityFail = class("SAttendFightActivityFail")
SAttendFightActivityFail.TYPEID = 12614162
SAttendFightActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendFightActivityFail.ROLE_STATUS_ERROR = -2
SAttendFightActivityFail.PARAM_ERROR = -3
SAttendFightActivityFail.CHECK_NPC_SERVICE_ERROR = -4
SAttendFightActivityFail.SERVER_LEVEL_NOT_ENOUGH = -5
SAttendFightActivityFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendFightActivityFail.ALREADY_FIGHT = 2
SAttendFightActivityFail.AWARD_FAIL = 3
SAttendFightActivityFail.TEAM_STATE_CHANGED = 4
SAttendFightActivityFail.ROLE_ID_NOT_TEAM_LEADER = 5
function SAttendFightActivityFail:ctor(res)
  self.id = 12614162
  self.res = res or nil
end
function SAttendFightActivityFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendFightActivityFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendFightActivityFail:sizepolicy(size)
  return size <= 65535
end
return SAttendFightActivityFail
