local SWatchRoundRobinFightRecordFail = class("SWatchRoundRobinFightRecordFail")
SWatchRoundRobinFightRecordFail.TYPEID = 12617032
SWatchRoundRobinFightRecordFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SWatchRoundRobinFightRecordFail.ROLE_STATUS_ERROR = -2
SWatchRoundRobinFightRecordFail.PARAM_ERROR = -3
SWatchRoundRobinFightRecordFail.CHECK_NPC_SERVICE_ERROR = -4
SWatchRoundRobinFightRecordFail.DB_ERROR = -5
SWatchRoundRobinFightRecordFail.WORLD_ERROR = -6
SWatchRoundRobinFightRecordFail.ACTIVITY_NOT_OPEN = 1
SWatchRoundRobinFightRecordFail.ACTIVITY_STAGE_ERROR = 2
SWatchRoundRobinFightRecordFail.NO_FIGHT = 3
SWatchRoundRobinFightRecordFail.NO_FIGHT_RECORD = 4
function SWatchRoundRobinFightRecordFail:ctor(res)
  self.id = 12617032
  self.res = res or nil
end
function SWatchRoundRobinFightRecordFail:marshal(os)
  os:marshalInt32(self.res)
end
function SWatchRoundRobinFightRecordFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SWatchRoundRobinFightRecordFail:sizepolicy(size)
  return size <= 65535
end
return SWatchRoundRobinFightRecordFail
