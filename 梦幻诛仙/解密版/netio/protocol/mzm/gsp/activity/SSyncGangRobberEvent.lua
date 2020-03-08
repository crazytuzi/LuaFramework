local SSyncGangRobberEvent = class("SSyncGangRobberEvent")
SSyncGangRobberEvent.TYPEID = 12587527
SSyncGangRobberEvent.GANG_ROBBER_BORN = 0
SSyncGangRobberEvent.GANG_ROBBER_SUCCESS = 1
SSyncGangRobberEvent.GANG_ROBBER_ALL_KILLED = 2
SSyncGangRobberEvent.DAY_KILLED_MORE_THAN_RECOMMAND = 3
SSyncGangRobberEvent.KILL_ALL_AWARD_TIP = 4
function SSyncGangRobberEvent:ctor(result)
  self.id = 12587527
  self.result = result or nil
end
function SSyncGangRobberEvent:marshal(os)
  os:marshalInt32(self.result)
end
function SSyncGangRobberEvent:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SSyncGangRobberEvent:sizepolicy(size)
  return size <= 65535
end
return SSyncGangRobberEvent
