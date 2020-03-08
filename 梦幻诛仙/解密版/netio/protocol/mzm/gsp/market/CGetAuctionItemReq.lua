local CGetAuctionItemReq = class("CGetAuctionItemReq")
CGetAuctionItemReq.TYPEID = 12601432
function CGetAuctionItemReq:ctor(marketId, itemId)
  self.id = 12601432
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function CGetAuctionItemReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function CGetAuctionItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function CGetAuctionItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetAuctionItemReq
