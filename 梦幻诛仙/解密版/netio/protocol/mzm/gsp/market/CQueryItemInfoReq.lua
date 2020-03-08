local CQueryItemInfoReq = class("CQueryItemInfoReq")
CQueryItemInfoReq.TYPEID = 12601346
function CQueryItemInfoReq:ctor(marketId, itemId, price)
  self.id = 12601346
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
end
function CQueryItemInfoReq:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
end
function CQueryItemInfoReq:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function CQueryItemInfoReq:sizepolicy(size)
  return size <= 65535
end
return CQueryItemInfoReq
