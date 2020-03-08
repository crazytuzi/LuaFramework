local SCanvassInCrossBattleFail = class("SCanvassInCrossBattleFail")
SCanvassInCrossBattleFail.TYPEID = 12616983
SCanvassInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SCanvassInCrossBattleFail.ROLE_STATUS_ERROR = -2
SCanvassInCrossBattleFail.PARAM_ERROR = -3
SCanvassInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SCanvassInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
SCanvassInCrossBattleFail.ACTIVITY_STAGE_ERROR = 2
SCanvassInCrossBattleFail.NOT_IN_CORPS = 3
SCanvassInCrossBattleFail.CORPS_NOT_REGISTER = 4
SCanvassInCrossBattleFail.CHAT_IN_TRUMPET_FAIL = 5
SCanvassInCrossBattleFail.IN_COOLDOWN_TIME = 6
function SCanvassInCrossBattleFail:ctor(res, canvass_timestamp)
  self.id = 12616983
  self.res = res or nil
  self.canvass_timestamp = canvass_timestamp or nil
end
function SCanvassInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
  os:marshalInt32(self.canvass_timestamp)
end
function SCanvassInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
  self.canvass_timestamp = os:unmarshalInt32()
end
function SCanvassInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SCanvassInCrossBattleFail
