local SEnterRoundRobinMapFail = class("SEnterRoundRobinMapFail")
SEnterRoundRobinMapFail.TYPEID = 12616980
SEnterRoundRobinMapFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SEnterRoundRobinMapFail.ROLE_STATUS_ERROR = -2
SEnterRoundRobinMapFail.PARAM_ERROR = -3
SEnterRoundRobinMapFail.CHECK_NPC_SERVICE_ERROR = -4
SEnterRoundRobinMapFail.DB_ERROR = -5
SEnterRoundRobinMapFail.WORLD_ERROR = -6
SEnterRoundRobinMapFail.ACTIVITY_NOT_OPEN = 1
SEnterRoundRobinMapFail.ACTIVITY_STAGE_ERROR = 2
SEnterRoundRobinMapFail.NOT_IN_TEAM = 3
SEnterRoundRobinMapFail.TEAM_STATE_CHANGED = 4
SEnterRoundRobinMapFail.ROLE_ID_NOT_TEAM_LEADER = 5
SEnterRoundRobinMapFail.TEAM_MEMBER_NOT_ENOUGH = 6
SEnterRoundRobinMapFail.NOT_IN_CORPS = 7
SEnterRoundRobinMapFail.NOT_ALL_TEAM_MEMBER_IN_SAME_CORPS = 8
SEnterRoundRobinMapFail.CAN_NOT_ATTEND_THIS_ROUND = 9
SEnterRoundRobinMapFail.NOT_ALL_TEAM_MEMBER_REGISTER = 10
SEnterRoundRobinMapFail.NOT_ALL_TEAM_MEMBER_NORMAL = 11
function SEnterRoundRobinMapFail:ctor(res)
  self.id = 12616980
  self.res = res or nil
end
function SEnterRoundRobinMapFail:marshal(os)
  os:marshalInt32(self.res)
end
function SEnterRoundRobinMapFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SEnterRoundRobinMapFail:sizepolicy(size)
  return size <= 65535
end
return SEnterRoundRobinMapFail
