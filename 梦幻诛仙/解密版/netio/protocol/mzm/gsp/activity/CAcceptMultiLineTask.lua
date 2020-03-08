local CAcceptMultiLineTask = class("CAcceptMultiLineTask")
CAcceptMultiLineTask.TYPEID = 12587608
function CAcceptMultiLineTask:ctor(activityId)
  self.id = 12587608
  self.activityId = activityId or nil
end
function CAcceptMultiLineTask:marshal(os)
  os:marshalInt32(self.activityId)
end
function CAcceptMultiLineTask:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CAcceptMultiLineTask:sizepolicy(size)
  return size <= 65535
end
return CAcceptMultiLineTask
