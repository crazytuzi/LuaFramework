local CUnConcernItemReq = class("CUnConcernItemReq")
CUnConcernItemReq.TYPEID = 12601384
function CUnConcernItemReq:ctor(marketId)
  self.id = 12601384
  self.marketId = marketId or nil
end
function CUnConcernItemReq:marshal(os)
  os:marshalInt64(self.marketId)
end
function CUnConcernItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function CUnConcernItemReq:sizepolicy(size)
  return size <= 65535
end
return CUnConcernItemReq
