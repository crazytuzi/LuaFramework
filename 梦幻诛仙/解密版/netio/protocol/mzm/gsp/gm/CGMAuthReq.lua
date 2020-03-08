local CGMAuthReq = class("CGMAuthReq")
CGMAuthReq.TYPEID = 12585730
function CGMAuthReq:ctor()
  self.id = 12585730
end
function CGMAuthReq:marshal(os)
end
function CGMAuthReq:unmarshal(os)
end
function CGMAuthReq:sizepolicy(size)
  return size <= 65535
end
return CGMAuthReq
