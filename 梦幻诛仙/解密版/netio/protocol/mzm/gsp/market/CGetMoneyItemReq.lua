local CGetMoneyItemReq = class("CGetMoneyItemReq")
CGetMoneyItemReq.TYPEID = 12601395
function CGetMoneyItemReq:ctor(marketId)
  self.id = 12601395
  self.marketId = marketId or nil
end
function CGetMoneyItemReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CGetMoneyItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CGetMoneyItemReq:sizepolicy(size)
  return size <= 65535
end
return CGetMoneyItemReq
