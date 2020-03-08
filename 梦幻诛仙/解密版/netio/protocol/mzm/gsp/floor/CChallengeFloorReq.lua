local CChallengeFloorReq = class("CChallengeFloorReq")
CChallengeFloorReq.TYPEID = 12617737
function CChallengeFloorReq:ctor(activityId, floor)
  self.id = 12617737
  self.activityId = activityId or nil
  self.floor = floor or nil
end
function CChallengeFloorReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.floor)
end
function CChallengeFloorReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.floor = os:unmarshalInt32()
end
function CChallengeFloorReq:sizepolicy(size)
  return size <= 65535
end
return CChallengeFloorReq
