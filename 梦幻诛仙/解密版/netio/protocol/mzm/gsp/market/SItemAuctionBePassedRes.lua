local SItemAuctionBePassedRes = class("SItemAuctionBePassedRes")
SItemAuctionBePassedRes.TYPEID = 12601445
function SItemAuctionBePassedRes:ctor(marketId, itemId, myprice, newprice)
  self.id = 12601445
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.myprice = myprice or nil
  self.newprice = newprice or nil
end
function SItemAuctionBePassedRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.myprice)
  os:marshalInt32(self.newprice)
end
function SItemAuctionBePassedRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.myprice = os:unmarshalInt32()
  self.newprice = os:unmarshalInt32()
end
function SItemAuctionBePassedRes:sizepolicy(size)
  return size <= 65535
end
return SItemAuctionBePassedRes
