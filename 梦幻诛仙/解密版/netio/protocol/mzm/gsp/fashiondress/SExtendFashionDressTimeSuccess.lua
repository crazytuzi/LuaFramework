local SExtendFashionDressTimeSuccess = class("SExtendFashionDressTimeSuccess")
SExtendFashionDressTimeSuccess.TYPEID = 12603142
function SExtendFashionDressTimeSuccess:ctor(fashionDressCfgId, leftTime)
  self.id = 12603142
  self.fashionDressCfgId = fashionDressCfgId or nil
  self.leftTime = leftTime or nil
end
function SExtendFashionDressTimeSuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
  os:marshalInt64(self.leftTime)
end
function SExtendFashionDressTimeSuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
  self.leftTime = os:unmarshalInt64()
end
function SExtendFashionDressTimeSuccess:sizepolicy(size)
  return size <= 65535
end
return SExtendFashionDressTimeSuccess
