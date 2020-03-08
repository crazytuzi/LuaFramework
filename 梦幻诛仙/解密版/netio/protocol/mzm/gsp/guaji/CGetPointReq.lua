local CGetPointReq = class("CGetPointReq")
CGetPointReq.TYPEID = 12591106
function CGetPointReq:ctor()
  self.id = 12591106
end
function CGetPointReq:marshal(os)
end
function CGetPointReq:unmarshal(os)
end
function CGetPointReq:sizepolicy(size)
  return size <= 32
end
return CGetPointReq
