local SGetAuctionPetRes = class("SGetAuctionPetRes")
SGetAuctionPetRes.TYPEID = 12601433
function SGetAuctionPetRes:ctor(marketId, petCfgId)
  self.id = 12601433
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function SGetAuctionPetRes:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function SGetAuctionPetRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function SGetAuctionPetRes:sizepolicy(size)
  return size <= 65535
end
return SGetAuctionPetRes
