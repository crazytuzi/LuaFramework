local CBuyPetReq = class("CBuyPetReq")
CBuyPetReq.TYPEID = 12601373
function CBuyPetReq:ctor(marketId, petCfgId, price)
  self.id = 12601373
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
  self.price = price or nil
end
function CBuyPetReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
  os:marshalInt32(self.price)
end
function CBuyPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CBuyPetReq:sizepolicy(size)
  return size <= 65535
end
return CBuyPetReq
