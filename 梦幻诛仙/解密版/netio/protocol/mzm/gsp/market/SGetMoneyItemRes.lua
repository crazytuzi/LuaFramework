local SGetMoneyItemRes = class("SGetMoneyItemRes")
SGetMoneyItemRes.TYPEID = 12601396
function SGetMoneyItemRes:ctor(marketId, itemId, money)
  self.id = 12601396
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.money = money or nil
end
function SGetMoneyItemRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.money)
end
function SGetMoneyItemRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.money = os:unmarshalInt32()
end
function SGetMoneyItemRes:sizepolicy(size)
  return size <= 65535
end
return SGetMoneyItemRes
