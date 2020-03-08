local SSyncPetExpire = class("SSyncPetExpire")
SSyncPetExpire.TYPEID = 12601370
function SSyncPetExpire:ctor(marketId, petCfgId)
  self.id = 12601370
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function SSyncPetExpire:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function SSyncPetExpire:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function SSyncPetExpire:sizepolicy(size)
  return size <= 65535
end
return SSyncPetExpire
