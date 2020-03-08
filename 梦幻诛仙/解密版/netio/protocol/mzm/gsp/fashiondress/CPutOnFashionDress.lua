local CPutOnFashionDress = class("CPutOnFashionDress")
CPutOnFashionDress.TYPEID = 12603141
function CPutOnFashionDress:ctor(fashionDressCfgId)
  self.id = 12603141
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function CPutOnFashionDress:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function CPutOnFashionDress:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function CPutOnFashionDress:sizepolicy(size)
  return size <= 65535
end
return CPutOnFashionDress
