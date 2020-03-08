local SGetRoundRobinPointInfoInCrossBattleFail = class("SGetRoundRobinPointInfoInCrossBattleFail")
SGetRoundRobinPointInfoInCrossBattleFail.TYPEID = 12617016
SGetRoundRobinPointInfoInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRoundRobinPointInfoInCrossBattleFail.ROLE_STATUS_ERROR = -2
SGetRoundRobinPointInfoInCrossBattleFail.PARAM_ERROR = -3
SGetRoundRobinPointInfoInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SGetRoundRobinPointInfoInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
function SGetRoundRobinPointInfoInCrossBattleFail:ctor(res)
  self.id = 12617016
  self.res = res or nil
end
function SGetRoundRobinPointInfoInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRoundRobinPointInfoInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRoundRobinPointInfoInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SGetRoundRobinPointInfoInCrossBattleFail
