local SUnSelectPropertySuccess = class("SUnSelectPropertySuccess")
SUnSelectPropertySuccess.TYPEID = 12603140
function SUnSelectPropertySuccess:ctor(fashionDressCfgId)
  self.id = 12603140
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SUnSelectPropertySuccess:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SUnSelectPropertySuccess:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SUnSelectPropertySuccess:sizepolicy(size)
  return size <= 65535
end
return SUnSelectPropertySuccess
