local CQuitInteractiveTaskReq = class("CQuitInteractiveTaskReq")
CQuitInteractiveTaskReq.TYPEID = 12610317
function CQuitInteractiveTaskReq:ctor(typeid)
  self.id = 12610317
  self.typeid = typeid or nil
end
function CQuitInteractiveTaskReq:marshal(os)
  os:marshalInt32(self.typeid)
end
function CQuitInteractiveTaskReq:unmarshal(os)
  self.typeid = os:unmarshalInt32()
end
function CQuitInteractiveTaskReq:sizepolicy(size)
  return size <= 65535
end
return CQuitInteractiveTaskReq
