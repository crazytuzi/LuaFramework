local SAttendMysteryVisitorFail = class("SAttendMysteryVisitorFail")
SAttendMysteryVisitorFail.TYPEID = 12605506
SAttendMysteryVisitorFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendMysteryVisitorFail.ROLE_STATUS_ERROR = -2
SAttendMysteryVisitorFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendMysteryVisitorFail.PARAM_ERROR = -4
SAttendMysteryVisitorFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendMysteryVisitorFail.AWARD_FAIL = 2
SAttendMysteryVisitorFail.NOT_SET_MYSTERY_VISITOR_CFG_ID = 3
SAttendMysteryVisitorFail.DO_NOT_HAVE_COURTYARD = 4
SAttendMysteryVisitorFail.MARRIAGE_STATE_CHANGED = 5
SAttendMysteryVisitorFail.ALREADY_SET_MYSTERY_VISITOR_CFG_ID = 6
SAttendMysteryVisitorFail.SEND_MAIL_FAIL = 7
SAttendMysteryVisitorFail.HAVE_COURTYARD = 8
SAttendMysteryVisitorFail.IS_TASK_TYPE = 9
function SAttendMysteryVisitorFail:ctor(res)
  self.id = 12605506
  self.res = res or nil
end
function SAttendMysteryVisitorFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendMysteryVisitorFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendMysteryVisitorFail:sizepolicy(size)
  return size <= 65535
end
return SAttendMysteryVisitorFail
