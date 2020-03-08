local CBuyItemReq = class("CBuyItemReq")
CBuyItemReq.TYPEID = 12601358
function CBuyItemReq:ctor(marketId, itemId, price, buyNum)
  self.id = 12601358
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.buyNum = buyNum or nil
end
function CBuyItemReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.buyNum)
end
function CBuyItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.buyNum = os:unmarshalInt32()
end
function CBuyItemReq:sizepolicy(size)
  return size <= 65535
end
return CBuyItemReq
