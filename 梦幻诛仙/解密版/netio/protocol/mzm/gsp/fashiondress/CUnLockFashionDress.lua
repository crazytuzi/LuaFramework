local CUnLockFashionDress = class("CUnLockFashionDress")
CUnLockFashionDress.TYPEID = 12603138
function CUnLockFashionDress:ctor(fashionDressCfgId)
  self.id = 12603138
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function CUnLockFashionDress:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function CUnLockFashionDress:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function CUnLockFashionDress:sizepolicy(size)
  return size <= 65535
end
return CUnLockFashionDress
