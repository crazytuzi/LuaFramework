local SDeletePetAuctionRes = class("SDeletePetAuctionRes")
SDeletePetAuctionRes.TYPEID = 12601429
function SDeletePetAuctionRes:ctor(marketId)
  self.id = 12601429
  self.marketId = marketId or nil
end
function SDeletePetAuctionRes:marshal(os)
  os:marshalInt64(self.marketId)
end
function SDeletePetAuctionRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function SDeletePetAuctionRes:sizepolicy(size)
  return size <= 65535
end
return SDeletePetAuctionRes
