local SAttendMoneyTreeFail = class("SAttendMoneyTreeFail")
SAttendMoneyTreeFail.TYPEID = 12611331
SAttendMoneyTreeFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SAttendMoneyTreeFail.ROLE_STATUS_ERROR = -2
SAttendMoneyTreeFail.CHECK_NPC_SERVICE_ERROR = -3
SAttendMoneyTreeFail.CAN_NOT_JOIN_ACTIVITY = 1
SAttendMoneyTreeFail.AWARD_FAIL = 2
function SAttendMoneyTreeFail:ctor(res)
  self.id = 12611331
  self.res = res or nil
end
function SAttendMoneyTreeFail:marshal(os)
  os:marshalInt32(self.res)
end
function SAttendMoneyTreeFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SAttendMoneyTreeFail:sizepolicy(size)
  return size <= 65535
end
return SAttendMoneyTreeFail
