local CGetPlayerInfoReq = class("CGetPlayerInfoReq")
CGetPlayerInfoReq.TYPEID = 12602115
function CGetPlayerInfoReq:ctor()
  self.id = 12602115
end
function CGetPlayerInfoReq:marshal(os)
end
function CGetPlayerInfoReq:unmarshal(os)
end
function CGetPlayerInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetPlayerInfoReq
