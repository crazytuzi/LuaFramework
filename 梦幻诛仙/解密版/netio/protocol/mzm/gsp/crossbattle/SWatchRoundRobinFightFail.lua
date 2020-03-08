local SWatchRoundRobinFightFail = class("SWatchRoundRobinFightFail")
SWatchRoundRobinFightFail.TYPEID = 12617031
SWatchRoundRobinFightFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SWatchRoundRobinFightFail.ROLE_STATUS_ERROR = -2
SWatchRoundRobinFightFail.PARAM_ERROR = -3
SWatchRoundRobinFightFail.CHECK_NPC_SERVICE_ERROR = -4
SWatchRoundRobinFightFail.DB_ERROR = -5
SWatchRoundRobinFightFail.WORLD_ERROR = -6
SWatchRoundRobinFightFail.ACTIVITY_NOT_OPEN = 1
SWatchRoundRobinFightFail.ACTIVITY_STAGE_ERROR = 2
SWatchRoundRobinFightFail.NO_FIGHT = 3
SWatchRoundRobinFightFail.CAN_NOT_WATCH_FIGHT = 4
function SWatchRoundRobinFightFail:ctor(res)
  self.id = 12617031
  self.res = res or nil
end
function SWatchRoundRobinFightFail:marshal(os)
  os:marshalInt32(self.res)
end
function SWatchRoundRobinFightFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SWatchRoundRobinFightFail:sizepolicy(size)
  return size <= 65535
end
return SWatchRoundRobinFightFail
