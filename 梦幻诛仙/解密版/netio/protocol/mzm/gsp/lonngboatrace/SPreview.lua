local SPreview = class("SPreview")
SPreview.TYPEID = 12619273
function SPreview:ctor(activityId, raceId)
  self.id = 12619273
  self.activityId = activityId or nil
  self.raceId = raceId or nil
end
function SPreview:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.raceId)
end
function SPreview:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.raceId = os:unmarshalInt32()
end
function SPreview:sizepolicy(size)
  return size <= 65535
end
return SPreview
