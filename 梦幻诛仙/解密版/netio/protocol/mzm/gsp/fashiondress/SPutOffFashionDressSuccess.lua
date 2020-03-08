local SPutOffFashionDressSuccess = class("SPutOffFashionDressSuccess")
SPutOffFashionDressSuccess.TYPEID = 12603143
function SPutOffFashionDressSuccess:ctor(fashionDressCfgId)
  self.id = 12603143
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SPutOffFashionDressSuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SPutOffFashionDressSuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SPutOffFashionDressSuccess:sizepolicy(size)
  return size <= 65535
end
return SPutOffFashionDressSuccess
