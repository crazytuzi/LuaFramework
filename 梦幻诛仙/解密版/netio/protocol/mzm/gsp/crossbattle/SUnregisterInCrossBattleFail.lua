local SUnregisterInCrossBattleFail = class("SUnregisterInCrossBattleFail")
SUnregisterInCrossBattleFail.TYPEID = 12616976
SUnregisterInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SUnregisterInCrossBattleFail.ROLE_STATUS_ERROR = -2
SUnregisterInCrossBattleFail.PARAM_ERROR = -3
SUnregisterInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SUnregisterInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
SUnregisterInCrossBattleFail.ACTIVITY_STAGE_ERROR = 2
SUnregisterInCrossBattleFail.NOT_IN_CORPS = 3
SUnregisterInCrossBattleFail.NOT_CORPS_LEADER = 4
SUnregisterInCrossBattleFail.CORPS_NOT_REGISTER = 5
function SUnregisterInCrossBattleFail:ctor(res)
  self.id = 12616976
  self.res = res or nil
end
function SUnregisterInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SUnregisterInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SUnregisterInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SUnregisterInCrossBattleFail
