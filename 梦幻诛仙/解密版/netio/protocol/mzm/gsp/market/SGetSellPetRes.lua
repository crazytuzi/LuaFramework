local SGetSellPetRes = class("SGetSellPetRes")
SGetSellPetRes.TYPEID = 12601359
function SGetSellPetRes:ctor(marketId, cutgold)
  self.id = 12601359
  self.marketId = marketId or nil
  self.cutgold = cutgold or nil
end
function SGetSellPetRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.cutgold)
end
function SGetSellPetRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.cutgold = os:unmarshalInt32()
end
function SGetSellPetRes:sizepolicy(size)
  return size <= 65535
end
return SGetSellPetRes
