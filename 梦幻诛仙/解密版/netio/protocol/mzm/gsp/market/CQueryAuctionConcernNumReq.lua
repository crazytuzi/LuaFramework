local CQueryAuctionConcernNumReq = class("CQueryAuctionConcernNumReq")
CQueryAuctionConcernNumReq.TYPEID = 12601449
function CQueryAuctionConcernNumReq:ctor(marketId, itemOrPet)
  self.id = 12601449
  self.marketId = marketId or nil
  self.itemOrPet = itemOrPet or nil
end
function CQueryAuctionConcernNumReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemOrPet)
end
function CQueryAuctionConcernNumReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemOrPet = os:unmarshalInt32()
end
function CQueryAuctionConcernNumReq:sizepolicy(size)
  return size <= 65535
end
return CQueryAuctionConcernNumReq
