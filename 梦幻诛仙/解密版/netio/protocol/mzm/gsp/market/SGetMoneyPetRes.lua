local SGetMoneyPetRes = class("SGetMoneyPetRes")
SGetMoneyPetRes.TYPEID = 12601398
function SGetMoneyPetRes:ctor(marketId, petCfgId, money)
  self.id = 12601398
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.money = money or nil
end
function SGetMoneyPetRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.money)
end
function SGetMoneyPetRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.money = os:unmarshalInt32()
end
function SGetMoneyPetRes:sizepolicy(size)
  return size <= 65535
end
return SGetMoneyPetRes
