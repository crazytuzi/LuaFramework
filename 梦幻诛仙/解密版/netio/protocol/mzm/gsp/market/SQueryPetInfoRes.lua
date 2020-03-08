local MarketPet = require("netio.protocol.mzm.gsp.market.MarketPet")
local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local SQueryPetInfoRes = class("SQueryPetInfoRes")
SQueryPetInfoRes.TYPEID = 12601348
function SQueryPetInfoRes:ctor(marketId, petCfgId, price, marketPet, petInfo, sellerRoleId)
  self.id = 12601348
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
  self.marketPet = marketPet or MarketPet.new()
  self.petInfo = petInfo or PetInfo.new()
  self.sellerRoleId = sellerRoleId or nil
end
function SQueryPetInfoRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
  self.marketPet:marshal(os)
  self.petInfo:marshal(os)
  os:marshalInt64(self.sellerRoleId)
end
function SQueryPetInfoRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.marketPet = MarketPet.new()
  self.marketPet:unmarshal(os)
  self.petInfo = PetInfo.new()
  self.petInfo:unmarshal(os)
  self.sellerRoleId = os:unmarshalInt64()
end
function SQueryPetInfoRes:sizepolicy(size)
  return size <= 65535
end
return SQueryPetInfoRes
