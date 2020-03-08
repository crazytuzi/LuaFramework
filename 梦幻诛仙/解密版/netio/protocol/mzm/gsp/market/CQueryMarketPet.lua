local CQueryMarketPet = class("CQueryMarketPet")
CQueryMarketPet.TYPEID = 12601366
function CQueryMarketPet:ctor(subid, pricesort, pageIndex)
  self.id = 12601366
  self.subid = subid or nil
  self.pricesort = pricesort or nil
  self.pageIndex = pageIndex or nil
end
function CQueryMarketPet:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.pageIndex)
end
function CQueryMarketPet:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CQueryMarketPet:sizepolicy(size)
  return size <= 65535
end
return CQueryMarketPet
