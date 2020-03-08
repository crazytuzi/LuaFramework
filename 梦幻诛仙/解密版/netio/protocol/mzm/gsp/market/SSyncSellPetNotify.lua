local SSyncSellPetNotify = class("SSyncSellPetNotify")
SSyncSellPetNotify.TYPEID = 12601372
function SSyncSellPetNotify:ctor(marketId, petCfgId)
  self.id = 12601372
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function SSyncSellPetNotify:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function SSyncSellPetNotify:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function SSyncSellPetNotify:sizepolicy(size)
  return size <= 65535
end
return SSyncSellPetNotify
