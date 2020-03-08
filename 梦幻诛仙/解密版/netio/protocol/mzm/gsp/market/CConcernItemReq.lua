local CConcernItemReq = class("CConcernItemReq")
CConcernItemReq.TYPEID = 12601376
function CConcernItemReq:ctor(marketId, itemId)
  self.id = 12601376
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function CConcernItemReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function CConcernItemReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function CConcernItemReq:sizepolicy(size)
  return size <= 65535
end
return CConcernItemReq
