local SBuyItemRes = class("SBuyItemRes")
SBuyItemRes.TYPEID = 12601361
function SBuyItemRes:ctor(marketId, itemId, price, buyNum, restNum, useMoney)
  self.id = 12601361
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.buyNum = buyNum or nil
  self.restNum = restNum or nil
  self.useMoney = useMoney or nil
end
function SBuyItemRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.buyNum)
  os:marshalInt32(self.restNum)
  os:marshalInt32(self.useMoney)
end
function SBuyItemRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.buyNum = os:unmarshalInt32()
  self.restNum = os:unmarshalInt32()
  self.useMoney = os:unmarshalInt32()
end
function SBuyItemRes:sizepolicy(size)
  return size <= 65535
end
return SBuyItemRes
