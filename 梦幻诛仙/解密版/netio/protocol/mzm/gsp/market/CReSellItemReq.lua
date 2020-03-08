local CReSellItemReq = class("CReSellItemReq")
CReSellItemReq.TYPEID = 12601351
function CReSellItemReq:ctor(marketId, itemId, price, num)
  self.id = 12601351
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.num = num or nil
end
function CReSellItemReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.num)
end
function CReSellItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
function CReSellItemReq:sizepolicy(size)
  return size <= 65535
end
return CReSellItemReq
