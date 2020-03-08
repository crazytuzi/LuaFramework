local SGetSellItemPriceRes = class("SGetSellItemPriceRes")
SGetSellItemPriceRes.TYPEID = 12592650
function SGetSellItemPriceRes:ctor(bagid, itemKey, itemId, price)
  self.id = 12592650
  self.bagid = bagid or nil
  self.itemKey = itemKey or nil
  self.itemId = itemId or nil
  self.price = price or nil
end
function SGetSellItemPriceRes:marshal(os)
  os:marshalInt32(self.bagid)
  os:marshalInt32(self.itemKey)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
end
function SGetSellItemPriceRes:unmarshal(os)
  self.bagid = os:unmarshalInt32()
  self.itemKey = os:unmarshalInt32()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
end
function SGetSellItemPriceRes:sizepolicy(size)
  return size <= 65535
end
return SGetSellItemPriceRes
