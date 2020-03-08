local SGetSellItemRes = class("SGetSellItemRes")
SGetSellItemRes.TYPEID = 12601371
function SGetSellItemRes:ctor(marketId, cutgold)
  self.id = 12601371
  self.marketId = marketId or nil
  self.cutgold = cutgold or nil
end
function SGetSellItemRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.cutgold)
end
function SGetSellItemRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.cutgold = os:unmarshalInt32()
end
function SGetSellItemRes:sizepolicy(size)
  return size <= 65535
end
return SGetSellItemRes
