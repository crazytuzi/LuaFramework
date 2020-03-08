local CActivityEndTimeReq = class("CActivityEndTimeReq")
CActivityEndTimeReq.TYPEID = 12587557
function CActivityEndTimeReq:ctor(activityId)
  self.id = 12587557
  self.activityId = activityId or nil
end
function CActivityEndTimeReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CActivityEndTimeReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CActivityEndTimeReq:sizepolicy(size)
  return size <= 65535
end
return CActivityEndTimeReq
