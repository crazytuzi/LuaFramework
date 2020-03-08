local CSelectProperty = class("CSelectProperty")
CSelectProperty.TYPEID = 12603147
function CSelectProperty:ctor(fashionDressCfgId)
  self.id = 12603147
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function CSelectProperty:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function CSelectProperty:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function CSelectProperty:sizepolicy(size)
  return size <= 65535
end
return CSelectProperty
