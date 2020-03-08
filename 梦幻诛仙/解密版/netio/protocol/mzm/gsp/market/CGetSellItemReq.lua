local CGetSellItemReq = class("CGetSellItemReq")
CGetSellItemReq.TYPEID = 12601352
function CGetSellItemReq:ctor(marketId, itemId)
  self.id = 12601352
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function CGetSellItemReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function CGetSellItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function CGetSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellItemReq
