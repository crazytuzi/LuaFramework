local SFlowerParadeJoinFailedRep = class("SFlowerParadeJoinFailedRep")
SFlowerParadeJoinFailedRep.TYPEID = 12625674
SFlowerParadeJoinFailedRep.PARADE_NOT_START = 1
SFlowerParadeJoinFailedRep.NOT_TEAM_LEADER = 2
function SFlowerParadeJoinFailedRep:ctor(code, activityId, nextStartTimeSec)
  self.id = 12625674
  self.code = code or nil
  self.activityId = activityId or nil
  self.nextStartTimeSec = nextStartTimeSec or nil
end
function SFlowerParadeJoinFailedRep:marshal(os)
  os:marshalInt32(self.code)
  os:marshalInt32(self.activityId)
  os:marshalInt64(self.nextStartTimeSec)
end
function SFlowerParadeJoinFailedRep:unmarshal(os)
  self.code = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
  self.nextStartTimeSec = os:unmarshalInt64()
end
function SFlowerParadeJoinFailedRep:sizepolicy(size)
  return size <= 65535
end
return SFlowerParadeJoinFailedRep
