local CEntry = class("CEntry")
CEntry.TYPEID = 12619272
function CEntry:ctor(activityId, raceId)
  self.id = 12619272
  self.activityId = activityId or nil
  self.raceId = raceId or nil
end
function CEntry:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.raceId)
end
function CEntry:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.raceId = os:unmarshalInt32()
end
function CEntry:sizepolicy(size)
  return size <= 65535
end
return CEntry
