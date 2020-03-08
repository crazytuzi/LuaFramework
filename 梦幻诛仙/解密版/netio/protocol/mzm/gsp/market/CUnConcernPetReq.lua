local CUnConcernPetReq = class("CUnConcernPetReq")
CUnConcernPetReq.TYPEID = 12601383
function CUnConcernPetReq:ctor(marketId)
  self.id = 12601383
  self.marketId = marketId or nil
end
function CUnConcernPetReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CUnConcernPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CUnConcernPetReq:sizepolicy(size)
  return size <= 65535
end
return CUnConcernPetReq
