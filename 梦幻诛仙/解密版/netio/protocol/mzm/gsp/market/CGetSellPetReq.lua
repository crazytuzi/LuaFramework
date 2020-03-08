local CGetSellPetReq = class("CGetSellPetReq")
CGetSellPetReq.TYPEID = 12601364
function CGetSellPetReq:ctor(marketId, petCfgId)
  self.id = 12601364
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function CGetSellPetReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function CGetSellPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function CGetSellPetReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellPetReq
