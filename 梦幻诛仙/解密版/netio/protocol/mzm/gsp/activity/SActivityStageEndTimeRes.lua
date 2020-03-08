local SActivityStageEndTimeRes = class("SActivityStageEndTimeRes")
SActivityStageEndTimeRes.TYPEID = 12587554
function SActivityStageEndTimeRes:ctor(activityId, stage, endTime)
  self.id = 12587554
  self.activityId = activityId or nil
  self.stage = stage or nil
  self.endTime = endTime or nil
end
function SActivityStageEndTimeRes:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.endTime)
end
function SActivityStageEndTimeRes:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.endTime = os:unmarshalInt32()
end
function SActivityStageEndTimeRes:sizepolicy(size)
  return size <= 65535
end
return SActivityStageEndTimeRes
