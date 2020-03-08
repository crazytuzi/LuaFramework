local CGetAuctionPetReq = class("CGetAuctionPetReq")
CGetAuctionPetReq.TYPEID = 12601434
function CGetAuctionPetReq:ctor(marketId, petCfgId)
  self.id = 12601434
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function CGetAuctionPetReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function CGetAuctionPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function CGetAuctionPetReq:sizepolicy(size)
  return size <= 65535
end
return CGetAuctionPetReq
