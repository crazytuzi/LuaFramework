local SQueryAuctionConcernNumRes = class("SQueryAuctionConcernNumRes")
SQueryAuctionConcernNumRes.TYPEID = 12601450
function SQueryAuctionConcernNumRes:ctor(marketId, itemOrPet, concernNum, auctionNum)
  self.id = 12601450
  self.marketId = marketId or nil
  self.itemOrPet = itemOrPet or nil
  self.concernNum = concernNum or nil
  self.auctionNum = auctionNum or nil
end
function SQueryAuctionConcernNumRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemOrPet)
  os:marshalInt32(self.concernNum)
  os:marshalInt32(self.auctionNum)
end
function SQueryAuctionConcernNumRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemOrPet = os:unmarshalInt32()
  self.concernNum = os:unmarshalInt32()
  self.auctionNum = os:unmarshalInt32()
end
function SQueryAuctionConcernNumRes:sizepolicy(size)
  return size <= 65535
end
return SQueryAuctionConcernNumRes
