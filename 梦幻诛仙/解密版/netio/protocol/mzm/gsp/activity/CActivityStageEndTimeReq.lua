local CActivityStageEndTimeReq = class("CActivityStageEndTimeReq")
CActivityStageEndTimeReq.TYPEID = 12587555
function CActivityStageEndTimeReq:ctor(activityId, stage)
  self.id = 12587555
  self.activityId = activityId or nil
  self.stage = stage or nil
end
function CActivityStageEndTimeReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.stage)
end
function CActivityStageEndTimeReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
end
function CActivityStageEndTimeReq:sizepolicy(size)
  return size <= 65535
end
return CActivityStageEndTimeReq
