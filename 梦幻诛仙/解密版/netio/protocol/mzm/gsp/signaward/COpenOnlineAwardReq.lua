local COpenOnlineAwardReq = class("COpenOnlineAwardReq")
COpenOnlineAwardReq.TYPEID = 12593419
function COpenOnlineAwardReq:ctor()
  self.id = 12593419
end
function COpenOnlineAwardReq:marshal(os)
end
function COpenOnlineAwardReq:unmarshal(os)
end
function COpenOnlineAwardReq:sizepolicy(size)
  return size <= 65535
end
return COpenOnlineAwardReq
