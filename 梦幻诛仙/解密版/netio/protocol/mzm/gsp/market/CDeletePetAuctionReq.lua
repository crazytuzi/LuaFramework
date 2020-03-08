local CDeletePetAuctionReq = class("CDeletePetAuctionReq")
CDeletePetAuctionReq.TYPEID = 12601428
function CDeletePetAuctionReq:ctor(marketId)
  self.id = 12601428
  self.marketId = marketId or nil
end
function CDeletePetAuctionReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CDeletePetAuctionReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CDeletePetAuctionReq:sizepolicy(size)
  return size <= 65535
end
return CDeletePetAuctionReq
