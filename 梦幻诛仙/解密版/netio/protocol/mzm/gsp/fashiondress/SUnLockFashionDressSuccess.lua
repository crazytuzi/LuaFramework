local SUnLockFashionDressSuccess = class("SUnLockFashionDressSuccess")
SUnLockFashionDressSuccess.TYPEID = 12603149
function SUnLockFashionDressSuccess:ctor(fashionDressCfgId)
  self.id = 12603149
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SUnLockFashionDressSuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SUnLockFashionDressSuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SUnLockFashionDressSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnLockFashionDressSuccess
