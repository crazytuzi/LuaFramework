local CBlacklistReq = class("CBlacklistReq")
CBlacklistReq.TYPEID = 12588545
function CBlacklistReq:ctor()
  self.id = 12588545
end
function CBlacklistReq:marshal(os)
end
function CBlacklistReq:unmarshal(os)
end
function CBlacklistReq:sizepolicy(size)
  return size <= 65535
end
return CBlacklistReq
