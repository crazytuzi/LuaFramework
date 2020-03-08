local CQueryMarketPublicItem = class("CQueryMarketPublicItem")
CQueryMarketPublicItem.TYPEID = 12601391
function CQueryMarketPublicItem:ctor(subid, pricesort, pageIndex)
  self.id = 12601391
  self.subid = subid or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CQueryMarketPublicItem:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CQueryMarketPublicItem:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CQueryMarketPublicItem:sizepolicy(size)
  return size <= 65535
end
return CQueryMarketPublicItem
