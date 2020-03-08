local CGetSellItemPriceReq = class("CGetSellItemPriceReq")
CGetSellItemPriceReq.TYPEID = 12592649
function CGetSellItemPriceReq:ctor(bagid, itemKey, itemId)
  self.id = 12592649
  self.bagid = bagid or nil
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
end
function CGetSellItemPriceReq:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
end
function CGetSellItemPriceReq:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
end
function CGetSellItemPriceReq:sizepolicy(size)
  return size <= 65535
end
return CGetSellItemPriceReq
