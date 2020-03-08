local CJoinLonngBoatRaceReq = class("CJoinLonngBoatRaceReq")
CJoinLonngBoatRaceReq.TYPEID = 12619269
function CJoinLonngBoatRaceReq:ctor(activityId, raceId)
  self.id = 12619269
  self.activityId = activityId or nil
  self.raceId = raceId or nil
end
function CJoinLonngBoatRaceReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.raceId)
end
function CJoinLonngBoatRaceReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.raceId = os:unmarshalInt32()
end
function CJoinLonngBoatRaceReq:sizepolicy(size)
  return size <= 65535
end
return CJoinLonngBoatRaceReq
