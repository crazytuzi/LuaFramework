local CUnSelectProperty = class("CUnSelectProperty")
CUnSelectProperty.TYPEID = 12603144
function CUnSelectProperty:ctor(fashionDressCfgId)
  self.id = 12603144
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function CUnSelectProperty:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function CUnSelectProperty:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function CUnSelectProperty:sizepolicy(size)
  return size <= 65535
end
return CUnSelectProperty
