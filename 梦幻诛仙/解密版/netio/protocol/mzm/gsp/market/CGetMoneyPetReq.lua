local CGetMoneyPetReq = class("CGetMoneyPetReq")
CGetMoneyPetReq.TYPEID = 12601394
function CGetMoneyPetReq:ctor(marketId)
  self.id = 12601394
  self.marketId = marketId or nil
end
function CGetMoneyPetReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CGetMoneyPetReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CGetMoneyPetReq:sizepolicy(size)
  return size <= 65535
end
return CGetMoneyPetReq
