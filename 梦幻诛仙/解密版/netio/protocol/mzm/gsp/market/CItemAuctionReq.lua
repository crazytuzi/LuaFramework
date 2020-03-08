local CItemAuctionReq = class("CItemAuctionReq")
CItemAuctionReq.TYPEID = 12601425
function CItemAuctionReq:ctor(marketId, itemId, price)
  self.id = 12601425
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
end
function CItemAuctionReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
end
function CItemAuctionReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CItemAuctionReq:sizepolicy(size)
  return size <= 65535
end
return CItemAuctionReq
