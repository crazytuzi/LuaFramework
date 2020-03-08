local SItemAuctionRes = class("SItemAuctionRes")
SItemAuctionRes.TYPEID = 12601421
function SItemAuctionRes:ctor(marketId, itemId, price, endTime)
  self.id = 12601421
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.endTime = endTime or nil
end
function SItemAuctionRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt64(self.endTime)
end
function SItemAuctionRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
end
function SItemAuctionRes:sizepolicy(size)
  return size <= 65535
end
return SItemAuctionRes
