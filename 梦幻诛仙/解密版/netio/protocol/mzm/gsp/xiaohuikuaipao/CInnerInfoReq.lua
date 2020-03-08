local CInnerInfoReq = class("CInnerInfoReq")
CInnerInfoReq.TYPEID = 12622852
function CInnerInfoReq:ctor(activityId)
  self.id = 12622852
  self.activityId = activityId or nil
end
function CInnerInfoReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CInnerInfoReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CInnerInfoReq:sizepolicy(size)
  return size <= 65535
end
return CInnerInfoReq
