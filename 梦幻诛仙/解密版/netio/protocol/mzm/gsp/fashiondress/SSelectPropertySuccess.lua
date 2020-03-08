local SSelectPropertySuccess = class("SSelectPropertySuccess")
SSelectPropertySuccess.TYPEID = 12603139
function SSelectPropertySuccess:ctor(fashionDressCfgId)
  self.id = 12603139
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SSelectPropertySuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SSelectPropertySuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SSelectPropertySuccess:sizepolicy(size)
  return size <= 65535
end
return SSelectPropertySuccess
