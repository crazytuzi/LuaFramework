local CQueryPetInfoReq = class("CQueryPetInfoReq")
CQueryPetInfoReq.TYPEID = 12601357
function CQueryPetInfoReq:ctor(marketId, petCfgId, price)
  self.id = 12601357
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
end
function CQueryPetInfoReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
end
function CQueryPetInfoReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CQueryPetInfoReq:sizepolicy(size)
  return size <= 65535
end
return CQueryPetInfoReq
