local SBetInFinalFail = class("SBetInFinalFail")
SBetInFinalFail.TYPEID = 12617074
SBetInFinalFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SBetInFinalFail.ROLE_STATUS_ERROR = -2
SBetInFinalFail.PARAM_ERROR = -3
SBetInFinalFail.CHECK_NPC_SERVICE_ERROR = -4
SBetInFinalFail.DB_ERROR = -5
SBetInFinalFail.COMMUNICATION_ERROR = 1
SBetInFinalFail.GET_STAGE_DATA_FAIL = 2
SBetInFinalFail.GET_STAGE_BET_DATA_FAIL = 3
SBetInFinalFail.NOT_IN_BET_TIME = 4
SBetInFinalFail.FIGHT_END = 5
SBetInFinalFail.NO_FIGHT_CORPS_ID = 6
SBetInFinalFail.CANNOT_BET_ON_OWN_FIGHT = 7
SBetInFinalFail.ALREADY_BET = 8
SBetInFinalFail.MONEY_NOT_ENOUGH = 9
SBetInFinalFail.FIGHT_NOT_EXIST = 10
SBetInFinalFail.LEVEL_NOT_ENOUGH = 11
SBetInFinalFail.ALREADY_HAS_ROUND_RESULT = 12
SBetInFinalFail.DAILY_BET_TIMES_TO_UPPER_LIMIT = 13
function SBetInFinalFail:ctor(res)
  self.id = 12617074
  self.res = res or nil
end
function SBetInFinalFail:marshal(os)
  os:marshalInt32(self.res)
end
function SBetInFinalFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SBetInFinalFail:sizepolicy(size)
  return size <= 65535
end
return SBetInFinalFail
