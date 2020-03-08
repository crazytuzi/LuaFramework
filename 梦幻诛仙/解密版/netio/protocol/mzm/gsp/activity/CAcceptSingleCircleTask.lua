local CAcceptSingleCircleTask = class("CAcceptSingleCircleTask")
CAcceptSingleCircleTask.TYPEID = 12587604
function CAcceptSingleCircleTask:ctor(activityId)
  self.id = 12587604
  self.activityId = activityId or nil
end
function CAcceptSingleCircleTask:marshal(os)
  os:marshalInt32(self.activityId)
end
function CAcceptSingleCircleTask:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CAcceptSingleCircleTask:sizepolicy(size)
  return size <= 65535
end
return CAcceptSingleCircleTask
