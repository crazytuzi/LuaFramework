local CPetAuctionReq = class("CPetAuctionReq")
CPetAuctionReq.TYPEID = 12601423
function CPetAuctionReq:ctor(marketId, petCfgId, price)
  self.id = 12601423
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
end
function CPetAuctionReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
end
function CPetAuctionReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CPetAuctionReq:sizepolicy(size)
  return size <= 65535
end
return CPetAuctionReq
