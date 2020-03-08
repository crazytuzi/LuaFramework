local CQueryMarketPetWithLevel = class("CQueryMarketPetWithLevel")
CQueryMarketPetWithLevel.TYPEID = 12601399
function CQueryMarketPetWithLevel:ctor(subid, pricesort, level, pubOrsell, pageIndex)
  self.id = 12601399
  self.subid = subid or nil
  self.pricesort = pricesort or nil
  self.level = level or nil
  self.pubOrsell = pubOrsell or nil
  self.pageIndex = pageIndex or nil
end
function CQueryMarketPetWithLevel:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.pricesort)
  os:marshalInt32(self.level)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt32(self.pageIndex)
end
function CQueryMarketPetWithLevel:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.pricesort = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.pubOrsell = os:unmarshalInt32()
  self.pageIndex = os:unmarshalInt32()
end
function CQueryMarketPetWithLevel:sizepolicy(size)
  return size <= 65535
end
return CQueryMarketPetWithLevel
