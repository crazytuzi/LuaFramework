local SBetInRoundRobinFail = class("SBetInRoundRobinFail")
SBetInRoundRobinFail.TYPEID = 12617038
SBetInRoundRobinFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SBetInRoundRobinFail.ROLE_STATUS_ERROR = -2
SBetInRoundRobinFail.PARAM_ERROR = -3
SBetInRoundRobinFail.CHECK_NPC_SERVICE_ERROR = -4
SBetInRoundRobinFail.ACTIVITY_NOT_OPEN = 1
SBetInRoundRobinFail.ACTIVITY_STAGE_ERROR = 2
SBetInRoundRobinFail.NOT_IN_BET_TIME = 3
SBetInRoundRobinFail.FIGHT_END = 4
SBetInRoundRobinFail.GET_REGISTER_ROLE_LIST_FAIL = 5
SBetInRoundRobinFail.CANNOT_BET_ON_OWN_FIGHT = 6
SBetInRoundRobinFail.ALREADY_BET = 7
SBetInRoundRobinFail.MONEY_NOT_ENOUGH = 8
SBetInRoundRobinFail.FIGHT_NOT_EXIST = 9
SBetInRoundRobinFail.LEVEL_NOT_ENOUGH = 10
function SBetInRoundRobinFail:ctor(res)
  self.id = 12617038
  self.res = res or nil
end
function SBetInRoundRobinFail:marshal(os)
  os:marshalInt32(self.res)
end
function SBetInRoundRobinFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SBetInRoundRobinFail:sizepolicy(size)
  return size <= 65535
end
return SBetInRoundRobinFail
