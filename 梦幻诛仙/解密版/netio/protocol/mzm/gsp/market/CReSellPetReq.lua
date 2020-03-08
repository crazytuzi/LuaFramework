local CReSellPetReq = class("CReSellPetReq")
CReSellPetReq.TYPEID = 12601347
function CReSellPetReq:ctor(marketId, price)
  self.id = 12601347
  self.marketId = marketId or nil
  self.price = price or nil
end
function CReSellPetReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.price)
end
function CReSellPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.price = os:unmarshalInt32()
end
function CReSellPetReq:sizepolicy(size)
  return size <= 65535
end
return CReSellPetReq
