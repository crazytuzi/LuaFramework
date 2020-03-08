local SGetRoundRobinRoundBetInfoFail = class("SGetRoundRobinRoundBetInfoFail")
SGetRoundRobinRoundBetInfoFail.TYPEID = 12617036
SGetRoundRobinRoundBetInfoFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRoundRobinRoundBetInfoFail.ROLE_STATUS_ERROR = -2
SGetRoundRobinRoundBetInfoFail.PARAM_ERROR = -3
SGetRoundRobinRoundBetInfoFail.CHECK_NPC_SERVICE_ERROR = -4
SGetRoundRobinRoundBetInfoFail.ACTIVITY_NOT_OPEN = 1
function SGetRoundRobinRoundBetInfoFail:ctor(res)
  self.id = 12617036
  self.res = res or nil
end
function SGetRoundRobinRoundBetInfoFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoundRobinRoundBetInfoFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoundRobinRoundBetInfoFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoundRobinRoundBetInfoFail
