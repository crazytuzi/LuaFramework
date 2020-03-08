local CGetAuthKeyReq = class("CGetAuthKeyReq")
CGetAuthKeyReq.TYPEID = 12602638
function CGetAuthKeyReq:ctor()
  self.id = 12602638
end
function CGetAuthKeyReq:marshal(os)
end
function CGetAuthKeyReq:unmarshal(os)
end
function CGetAuthKeyReq:sizepolicy(size)
  return size <= 65535
end
return CGetAuthKeyReq
