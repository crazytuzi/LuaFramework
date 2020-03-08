local SUnConcernItemRes = class("SUnConcernItemRes")
SUnConcernItemRes.TYPEID = 12601385
function SUnConcernItemRes:ctor(marketId)
  self.id = 12601385
  self.marketId = marketId or nil
end
function SUnConcernItemRes:marshal(os)
  os:marshalInt64(self.marketId)
end
function SUnConcernItemRes:unmarshal(os)
  self.marketId = os:unmarshalInt64()
end
function SUnConcernItemRes:sizepolicy(size)
  return size <= 65535
end
return SUnConcernItemRes
