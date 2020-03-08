local CRefreshOpponentReq = class("CRefreshOpponentReq")
CRefreshOpponentReq.TYPEID = 12595721
function CRefreshOpponentReq:ctor()
  self.id = 12595721
end
function CRefreshOpponentReq:marshal(os)
end
function CRefreshOpponentReq:unmarshal(os)
end
function CRefreshOpponentReq:sizepolicy(size)
  return size <= 65535
end
return CRefreshOpponentReq
