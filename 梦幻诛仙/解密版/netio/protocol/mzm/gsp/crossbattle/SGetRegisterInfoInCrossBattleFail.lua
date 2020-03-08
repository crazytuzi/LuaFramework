local SGetRegisterInfoInCrossBattleFail = class("SGetRegisterInfoInCrossBattleFail")
SGetRegisterInfoInCrossBattleFail.TYPEID = 12616967
SGetRegisterInfoInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetRegisterInfoInCrossBattleFail.ROLE_STATUS_ERROR = -2
SGetRegisterInfoInCrossBattleFail.PARAM_ERROR = -3
SGetRegisterInfoInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SGetRegisterInfoInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
function SGetRegisterInfoInCrossBattleFail:ctor(res)
  self.id = 12616967
  self.res = res or nil
end
function SGetRegisterInfoInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetRegisterInfoInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetRegisterInfoInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SGetRegisterInfoInCrossBattleFail
