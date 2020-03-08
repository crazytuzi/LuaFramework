local SRegisterInCrossBattleFail = class("SRegisterInCrossBattleFail")
SRegisterInCrossBattleFail.TYPEID = 12616961
SRegisterInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SRegisterInCrossBattleFail.ROLE_STATUS_ERROR = -2
SRegisterInCrossBattleFail.PARAM_ERROR = -3
SRegisterInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SRegisterInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
SRegisterInCrossBattleFail.ACTIVITY_STAGE_ERROR = 2
SRegisterInCrossBattleFail.NOT_IN_CORPS = 3
SRegisterInCrossBattleFail.NOT_CORPS_LEADER = 4
SRegisterInCrossBattleFail.CORPS_MEMBER_NUM_DISSATISFIED = 5
SRegisterInCrossBattleFail.CORPS_ALREADY_REGISTER = 6
SRegisterInCrossBattleFail.MONEY_NOT_ENOUGH = 7
function SRegisterInCrossBattleFail:ctor(res)
  self.id = 12616961
  self.res = res or nil
end
function SRegisterInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SRegisterInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SRegisterInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SRegisterInCrossBattleFail
