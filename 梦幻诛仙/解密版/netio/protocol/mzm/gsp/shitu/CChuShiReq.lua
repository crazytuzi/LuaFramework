local CChuShiReq = class("CChuShiReq")
CChuShiReq.TYPEID = 12601617
function CChuShiReq:ctor()
  self.id = 12601617
end
function CChuShiReq:marshal(os)
end
function CChuShiReq:unmarshal(os)
end
function CChuShiReq:sizepolicy(size)
  return size <= 65535
end
return CChuShiReq
