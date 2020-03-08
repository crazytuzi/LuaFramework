local CJoinInteractiveTaskReq = class("CJoinInteractiveTaskReq")
CJoinInteractiveTaskReq.TYPEID = 12610316
function CJoinInteractiveTaskReq:ctor(typeid)
  self.id = 12610316
  self.typeid = typeid or nil
end
function CJoinInteractiveTaskReq:marshal(os)
  os:marshalInt32(self.typeid)
end
function CJoinInteractiveTaskReq:unmarshal(os)
  self.typeid = os:unmarshalInt32()
end
function CJoinInteractiveTaskReq:sizepolicy(size)
  return size <= 65535
end
return CJoinInteractiveTaskReq
