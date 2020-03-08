local SBetInSelectionFail = class("SBetInSelectionFail")
SBetInSelectionFail.TYPEID = 12617041
SBetInSelectionFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SBetInSelectionFail.ROLE_STATUS_ERROR = -2
SBetInSelectionFail.PARAM_ERROR = -3
SBetInSelectionFail.CHECK_NPC_SERVICE_ERROR = -4
SBetInSelectionFail.DB_ERROR = -5
SBetInSelectionFail.COMMUNICATION_ERROR = 1
SBetInSelectionFail.GET_STAGE_DATA_FAIL = 2
SBetInSelectionFail.GET_STAGE_BET_DATA_FAIL = 3
SBetInSelectionFail.NOT_IN_BET_TIME = 4
SBetInSelectionFail.FIGHT_END = 5
SBetInSelectionFail.NO_FIGHT_CORPS_ID = 6
SBetInSelectionFail.CANNOT_BET_ON_OWN_FIGHT = 7
SBetInSelectionFail.ALREADY_BET = 8
SBetInSelectionFail.MONEY_NOT_ENOUGH = 9
SBetInSelectionFail.FIGHT_NOT_EXIST = 10
SBetInSelectionFail.LEVEL_NOT_ENOUGH = 11
SBetInSelectionFail.ALREADY_HAS_ROUND_RESULT = 12
SBetInSelectionFail.DAILY_BET_TIMES_TO_UPPER_LIMIT = 13
function SBetInSelectionFail:ctor(res)
  self.id = 12617041
  self.res = res or nil
end
function SBetInSelectionFail:marshal(os)
  os:marshalInt32(self.res)
end
function SBetInSelectionFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SBetInSelectionFail:sizepolicy(size)
  return size <= 65535
end
return SBetInSelectionFail
