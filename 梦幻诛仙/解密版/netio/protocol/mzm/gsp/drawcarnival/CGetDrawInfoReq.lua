local CGetDrawInfoReq = class("CGetDrawInfoReq")
CGetDrawInfoReq.TYPEID = 12630024
function CGetDrawInfoReq:ctor()
  self.id = 12630024
end
function CGetDrawInfoReq:marshal(os)
end
function CGetDrawInfoReq:unmarshal(os)
end
function CGetDrawInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetDrawInfoReq
