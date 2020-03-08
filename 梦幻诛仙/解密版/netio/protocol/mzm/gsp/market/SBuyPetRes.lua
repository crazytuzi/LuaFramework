local SBuyPetRes = class("SBuyPetRes")
SBuyPetRes.TYPEID = 12601350
function SBuyPetRes:ctor(marketId, petCfgId, price, useMoney)
  self.id = 12601350
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
  self.useMoney = useMoney or nil
end
function SBuyPetRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.useMoney)
end
function SBuyPetRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.useMoney = os:unmarshalInt32()
end
function SBuyPetRes:sizepolicy(size)
  return size <= 65535
end
return SBuyPetRes
