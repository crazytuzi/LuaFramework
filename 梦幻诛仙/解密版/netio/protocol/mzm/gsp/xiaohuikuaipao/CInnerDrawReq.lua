local CInnerDrawReq = class("CInnerDrawReq")
CInnerDrawReq.TYPEID = 12622859
function CInnerDrawReq:ctor(activityId)
  self.id = 12622859
  self.activityId = activityId or nil
end
function CInnerDrawReq:marshal(os)
  os:marshalInt32(self.activityId)
end
function CInnerDrawReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
end
function CInnerDrawReq:sizepolicy(size)
  return size <= 65535
end
return CInnerDrawReq
