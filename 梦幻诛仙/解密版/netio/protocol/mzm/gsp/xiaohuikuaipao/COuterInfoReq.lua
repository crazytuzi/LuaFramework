local COuterInfoReq = class("COuterInfoReq")
COuterInfoReq.TYPEID = 12622856
function COuterInfoReq:ctor(activityId)
  self.id = 12622856
  self.activityId = activityId or nil
end
function COuterInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function COuterInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function COuterInfoReq:sizepolicy(size)
  return size <= 65535
end
return COuterInfoReq
