local CQueryAllAuctionReq = class("CQueryAllAuctionReq")
CQueryAllAuctionReq.TYPEID = 12601427
function CQueryAllAuctionReq:ctor()
  self.id = 12601427
end
function CQueryAllAuctionReq:marshal(os)
end
function CQueryAllAuctionReq:unmarshal(os)
end
function CQueryAllAuctionReq:sizepolicy(size)
  return size <= 65535
end
return CQueryAllAuctionReq
