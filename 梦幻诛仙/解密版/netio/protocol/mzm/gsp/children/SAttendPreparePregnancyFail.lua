local SAttendPreparePregnancyFail = class("SAttendPreparePregnancyFail")
SAttendPreparePregnancyFail.TYPEID = 12609340
SAttendPreparePregnancyFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendPreparePregnancyFail.ROLE_STATUS_ERROR = -2
SAttendPreparePregnancyFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendPreparePregnancyFail.INVITER_IS_NOT_IN_TEAM = 1
SAttendPreparePregnancyFail.TEAM_MEMBER_NUM_ERROR = 2
SAttendPreparePregnancyFail.INVITER_IS_NOT_TEAM_LEADER = 3
SAttendPreparePregnancyFail.INVITEE_IS_NOT_TEAM_MEMBER = 4
SAttendPreparePregnancyFail.TEAM_NOT_EXIST = 5
SAttendPreparePregnancyFail.NOT_COUPLE = 6
SAttendPreparePregnancyFail.CAN_NOT_JOIN_ACTIVITY = 7
SAttendPreparePregnancyFail.INVITE_TIMEOUT = 8
SAttendPreparePregnancyFail.PARTNER_REFUSE = 9
SAttendPreparePregnancyFail.CHILD_NUM_TO_UPPER_LIMIT = 10
SAttendPreparePregnancyFail.BREED_STATE_ERROR = 11
SAttendPreparePregnancyFail.POINT_TO_UPPER_LIMIT = 12
function SAttendPreparePregnancyFail:ctor(res)
  self.id = 12609340
  self.res = res or nil
end
function SAttendPreparePregnancyFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendPreparePregnancyFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendPreparePregnancyFail:sizepolicy(size)
  return size <= 65535
end
return SAttendPreparePregnancyFail
