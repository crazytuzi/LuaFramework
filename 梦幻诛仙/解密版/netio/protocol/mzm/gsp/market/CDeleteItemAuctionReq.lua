local CDeleteItemAuctionReq = class("CDeleteItemAuctionReq")
CDeleteItemAuctionReq.TYPEID = 12601422
function CDeleteItemAuctionReq:ctor(marketId)
  self.id = 12601422
  self.marketId = marketId or nil
end
function CDeleteItemAuctionReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CDeleteItemAuctionReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CDeleteItemAuctionReq:sizepolicy(size)
  return size <= 65535
end
return CDeleteItemAuctionReq
