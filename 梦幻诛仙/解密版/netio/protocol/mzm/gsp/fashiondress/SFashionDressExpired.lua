local SFashionDressExpired = class("SFashionDressExpired")
SFashionDressExpired.TYPEID = 12603148
function SFashionDressExpired:ctor(fashionDressCfgId)
  self.id = 12603148
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SFashionDressExpired:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
end
function SFashionDressExpired:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SFashionDressExpired:sizepolicy(size)
  return size <= 65535
end
return SFashionDressExpired
