local CPutOffFashionDress = class("CPutOffFashionDress")
CPutOffFashionDress.TYPEID = 12603146
function CPutOffFashionDress:ctor(fashionDressCfgId)
  self.id = 12603146
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function CPutOffFashionDress:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function CPutOffFashionDress:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function CPutOffFashionDress:sizepolicy(size)
  return size <= 65535
end
return CPutOffFashionDress
