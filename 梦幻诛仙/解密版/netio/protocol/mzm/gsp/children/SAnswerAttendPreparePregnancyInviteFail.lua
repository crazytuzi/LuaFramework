local SAnswerAttendPreparePregnancyInviteFail = class("SAnswerAttendPreparePregnancyInviteFail")
SAnswerAttendPreparePregnancyInviteFail.TYPEID = 12609344
SAnswerAttendPreparePregnancyInviteFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAnswerAttendPreparePregnancyInviteFail.ROLE_STATUS_ERROR = -2
SAnswerAttendPreparePregnancyInviteFail.PARAM_ERROR = -3
SAnswerAttendPreparePregnancyInviteFail.SESSION_CONTEXT_NOT_MATCH = -4
SAnswerAttendPreparePregnancyInviteFail.INVITER_IS_NOT_IN_TEAM = 1
SAnswerAttendPreparePregnancyInviteFail.TEAM_MEMBER_NUM_ERROR = 2
SAnswerAttendPreparePregnancyInviteFail.INVITER_IS_NOT_TEAM_LEADER = 3
SAnswerAttendPreparePregnancyInviteFail.INVITEE_IS_NOT_TEAM_MEMBER = 4
SAnswerAttendPreparePregnancyInviteFail.TEAM_NOT_EXIST = 5
SAnswerAttendPreparePregnancyInviteFail.NOT_COUPLE = 6
SAnswerAttendPreparePregnancyInviteFail.CAN_NOT_JOIN_ACTIVITY = 7
SAnswerAttendPreparePregnancyInviteFail.INVITE_TIMEOUT = 8
SAnswerAttendPreparePregnancyInviteFail.OTHER_GAME_NOT_OVER = 9
SAnswerAttendPreparePregnancyInviteFail.CHILD_NUM_TO_UPPER_LIMIT = 10
SAnswerAttendPreparePregnancyInviteFail.BREED_STATE_ERROR = 11
SAnswerAttendPreparePregnancyInviteFail.POINT_TO_UPPER_LIMIT = 12
function SAnswerAttendPreparePregnancyInviteFail:ctor(res)
  self.id = 12609344
  self.res = res or nil
end
function SAnswerAttendPreparePregnancyInviteFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAnswerAttendPreparePregnancyInviteFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAnswerAttendPreparePregnancyInviteFail:sizepolicy(size)
  return size <= 65535
end
return SAnswerAttendPreparePregnancyInviteFail
