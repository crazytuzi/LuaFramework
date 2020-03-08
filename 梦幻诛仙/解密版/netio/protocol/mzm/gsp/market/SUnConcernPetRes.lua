local SUnConcernPetRes = class("SUnConcernPetRes")
SUnConcernPetRes.TYPEID = 12601386
function SUnConcernPetRes:ctor(marketId)
  self.id = 12601386
  self.marketId = marketId or nil
end
function SUnConcernPetRes:marshal(os)
  os:marshalInt64(self.marketId)
end
function SUnConcernPetRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function SUnConcernPetRes:sizepolicy(size)
  return size <= 65535
end
return SUnConcernPetRes
