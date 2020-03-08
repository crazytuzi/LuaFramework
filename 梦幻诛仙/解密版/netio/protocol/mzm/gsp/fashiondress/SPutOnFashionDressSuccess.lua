local SPutOnFashionDressSuccess = class("SPutOnFashionDressSuccess")
SPutOnFashionDressSuccess.TYPEID = 12603137
function SPutOnFashionDressSuccess:ctor(fashionDressCfgId)
  self.id = 12603137
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SPutOnFashionDressSuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SPutOnFashionDressSuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SPutOnFashionDressSuccess:sizepolicy(size)
  return size <= 65535
end
return SPutOnFashionDressSuccess
