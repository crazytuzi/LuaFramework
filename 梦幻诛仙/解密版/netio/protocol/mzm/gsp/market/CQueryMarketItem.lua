local CQueryMarketItem = class("CQueryMarketItem")
CQueryMarketItem.TYPEID = 12601345
function CQueryMarketItem:ctor(subid, pricesort, pageIndex)
  self.id = 12601345
  self.subid = subid or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CQueryMarketItem:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CQueryMarketItem:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CQueryMarketItem:sizepolicy(size)
  return size <= 65535
end
return CQueryMarketItem
