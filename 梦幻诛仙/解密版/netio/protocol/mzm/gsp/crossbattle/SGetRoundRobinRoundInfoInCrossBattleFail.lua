local SGetRoundRobinRoundInfoInCrossBattleFail = class("SGetRoundRobinRoundInfoInCrossBattleFail")
SGetRoundRobinRoundInfoInCrossBattleFail.TYPEID = 12617007
SGetRoundRobinRoundInfoInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRoundRobinRoundInfoInCrossBattleFail.ROLE_STATUS_ERROR = -2
SGetRoundRobinRoundInfoInCrossBattleFail.PARAM_ERROR = -3
SGetRoundRobinRoundInfoInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SGetRoundRobinRoundInfoInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
function SGetRoundRobinRoundInfoInCrossBattleFail:ctor(res)
  self.id = 12617007
  self.res = res or nil
end
function SGetRoundRobinRoundInfoInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoundRobinRoundInfoInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoundRobinRoundInfoInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoundRobinRoundInfoInCrossBattleFail
