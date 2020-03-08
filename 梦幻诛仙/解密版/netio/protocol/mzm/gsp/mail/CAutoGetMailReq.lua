local CAutoGetMailReq = class("CAutoGetMailReq")
CAutoGetMailReq.TYPEID = 12592907
function CAutoGetMailReq:ctor()
  self.id = 12592907
end
function CAutoGetMailReq:marshal(os)
end
function CAutoGetMailReq:unmarshal(os)
end
function CAutoGetMailReq:sizepolicy(size)
  return size <= 65535
end
return CAutoGetMailReq
