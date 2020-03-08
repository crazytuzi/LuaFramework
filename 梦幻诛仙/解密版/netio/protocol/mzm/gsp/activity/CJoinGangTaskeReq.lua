local CJoinGangTaskeReq = class("CJoinGangTaskeReq")
CJoinGangTaskeReq.TYPEID = 12587570
function CJoinGangTaskeReq:ctor()
  self.id = 12587570
end
function CJoinGangTaskeReq:marshal(os)
end
function CJoinGangTaskeReq:unmarshal(os)
end
function CJoinGangTaskeReq:sizepolicy(size)
  return size <= 65535
end
return CJoinGangTaskeReq
