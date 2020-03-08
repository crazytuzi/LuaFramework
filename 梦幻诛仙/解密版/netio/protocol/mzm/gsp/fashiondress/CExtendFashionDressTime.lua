local CExtendFashionDressTime = class("CExtendFashionDressTime")
CExtendFashionDressTime.TYPEID = 12603150
function CExtendFashionDressTime:ctor(fashionDressCfgId, use_item_num)
  self.id = 12603150
  self.fashionDressCfgId = fashionDressCfgId or nil
  self.use_item_num = use_item_num or nil
end
function CExtendFashionDressTime:marshal(os)
  os:marshalInt32(self.fashionDressCfgId)
  os:marshalInt32(self.use_item_num)
end
function CExtendFashionDressTime:unmarshal(os)
  self.fashionDressCfgId = os:unmarshalInt32()
  self.use_item_num = os:unmarshalInt32()
end
function CExtendFashionDressTime:sizepolicy(size)
  return size <= 65535
end
return CExtendFashionDressTime
