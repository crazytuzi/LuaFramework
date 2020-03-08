local SGetActivityCompleteAwardFail = class("SGetActivityCompleteAwardFail")
SGetActivityCompleteAwardFail.TYPEID = 12611600
SGetActivityCompleteAwardFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetActivityCompleteAwardFail.ROLE_STATUS_ERROR = -2
SGetActivityCompleteAwardFail.PARAM_ERROR = -3
SGetActivityCompleteAwardFail.DB_ERROR = -4
SGetActivityCompleteAwardFail.CAN_NOT_JOIN_ACTIVITY = 1
SGetActivityCompleteAwardFail.ALREADY_GET_AWARD = 2
SGetActivityCompleteAwardFail.ACTIVITY_NOT_COMPLETE = 3
SGetActivityCompleteAwardFail.AWARD_FAIL = 4
function SGetActivityCompleteAwardFail:ctor(res)
  self.id = 12611600
  self.res = res or nil
end
function SGetActivityCompleteAwardFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetActivityCompleteAwardFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetActivityCompleteAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetActivityCompleteAwardFail
