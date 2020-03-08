local SItemAuctionSuccessRes = class("SItemAuctionSuccessRes")
SItemAuctionSuccessRes.TYPEID = 12601448
function SItemAuctionSuccessRes:ctor(marketId, itemId)
  self.id = 12601448
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function SItemAuctionSuccessRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function SItemAuctionSuccessRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function SItemAuctionSuccessRes:sizepolicy(size)
  return size <= 65535
end
return SItemAuctionSuccessRes
