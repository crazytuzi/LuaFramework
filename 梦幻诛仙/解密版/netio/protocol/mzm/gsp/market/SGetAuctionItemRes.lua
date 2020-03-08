local SGetAuctionItemRes = class("SGetAuctionItemRes")
SGetAuctionItemRes.TYPEID = 12601435
function SGetAuctionItemRes:ctor(marketId, itemId)
  self.id = 12601435
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function SGetAuctionItemRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function SGetAuctionItemRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function SGetAuctionItemRes:sizepolicy(size)
  return size <= 65535
end
return SGetAuctionItemRes
