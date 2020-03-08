local CGetFuLiReq = class("CGetFuLiReq")
CGetFuLiReq.TYPEID = 12589924
function CGetFuLiReq:ctor()
  self.id = 12589924
end
function CGetFuLiReq:marshal(os)
end
function CGetFuLiReq:unmarshal(os)
end
function CGetFuLiReq:sizepolicy(size)
  return size <= 65535
end
return CGetFuLiReq
