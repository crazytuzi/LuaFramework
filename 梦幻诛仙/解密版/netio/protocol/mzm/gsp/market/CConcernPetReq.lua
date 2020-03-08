local CConcernPetReq = class("CConcernPetReq")
CConcernPetReq.TYPEID = 12601381
function CConcernPetReq:ctor(marketId, petCfgId)
  self.id = 12601381
  self.marketId = marketId or nil
  self.petCfgId = petCfgId or nil
end
function CConcernPetReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.petCfgId)
end
function CConcernPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.petCfgId = os:unmarshalInt32()
end
function CConcernPetReq:sizepolicy(size)
  return size <= 65535
end
return CConcernPetReq
