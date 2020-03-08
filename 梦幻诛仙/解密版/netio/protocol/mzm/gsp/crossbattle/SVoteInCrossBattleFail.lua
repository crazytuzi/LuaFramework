local SVoteInCrossBattleFail = class("SVoteInCrossBattleFail")
SVoteInCrossBattleFail.TYPEID = 12616962
SVoteInCrossBattleFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SVoteInCrossBattleFail.ROLE_STATUS_ERROR = -2
SVoteInCrossBattleFail.PARAM_ERROR = -3
SVoteInCrossBattleFail.CHECK_NPC_SERVICE_ERROR = -4
SVoteInCrossBattleFail.ACTIVITY_NOT_OPEN = 1
SVoteInCrossBattleFail.ACTIVITY_STAGE_ERROR = 2
SVoteInCrossBattleFail.CORPS_NOT_REGISTER = 3
SVoteInCrossBattleFail.VOTE_TIME_TO_LIMIT = 4
SVoteInCrossBattleFail.VOTE_AWARD_FAIL = 5
SVoteInCrossBattleFail.LEVEL_NOT_ENOUGH = 6
function SVoteInCrossBattleFail:ctor(res)
  self.id = 12616962
  self.res = res or nil
end
function SVoteInCrossBattleFail:marshal(os)
  os:marshalInt32(self.res)
end
function SVoteInCrossBattleFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SVoteInCrossBattleFail:sizepolicy(size)
  return size <= 65535
end
return SVoteInCrossBattleFail
