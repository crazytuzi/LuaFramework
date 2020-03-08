local SActivityEndTimeRes = class("SActivityEndTimeRes")
SActivityEndTimeRes.TYPEID = 12587556
function SActivityEndTimeRes:ctor(activityId, endTime)
  self.id = 12587556
  self.activityId = activityId or nil
  self.endTime = endTime or nil
end
function SActivityEndTimeRes:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.endTime)
end
function SActivityEndTimeRes:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.endTime = os:unmarshalInt32()
end
function SActivityEndTimeRes:sizepolicy(size)
  return size <= 65535
end
return SActivityEndTimeRes
