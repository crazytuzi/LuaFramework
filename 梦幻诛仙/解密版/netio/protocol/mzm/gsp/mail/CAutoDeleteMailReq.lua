local CAutoDeleteMailReq = class("CAutoDeleteMailReq")
CAutoDeleteMailReq.TYPEID = 12592909
function CAutoDeleteMailReq:ctor()
  self.id = 12592909
end
function CAutoDeleteMailReq:marshal(os)
end
function CAutoDeleteMailReq:unmarshal(os)
end
function CAutoDeleteMailReq:sizepolicy(size)
  return size <= 65535
end
return CAutoDeleteMailReq
