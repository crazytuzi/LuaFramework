local CQueryMarketPublicPet = class("CQueryMarketPublicPet")
CQueryMarketPublicPet.TYPEID = 12601389
function CQueryMarketPublicPet:ctor(subid, pricesort, pageIndex)
  self.id = 12601389
  self.subid = subid or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CQueryMarketPublicPet:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CQueryMarketPublicPet:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CQueryMarketPublicPet:sizepolicy(size)
  return size <= 65535
end
return CQueryMarketPublicPet
