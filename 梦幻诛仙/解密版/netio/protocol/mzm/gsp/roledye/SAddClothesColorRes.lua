local SAddClothesColorRes = class("SAddClothesColorRes")
SAddClothesColorRes.TYPEID = 12597249
function SAddClothesColorRes:ctor(colorid, hairid, clothid, fashionDressCfgId)
  self.id = 12597249
  self.colorid = colorid or nil
  self.hairid = hairid or nil
  self.clothid = clothid or nil
  self.fashionDressCfgId = fashionDressCfgId or nil
end
function SAddClothesColorRes:marshal(os)
  os:marshalInt32(self.colorid)
  os:marshalInt32(self.hairid)
  os:marshalInt32(self.clothid)
  os:marshalInt32(self.fashionDressCfgId)
end
function SAddClothesColorRes:unmarshal(os)
  self.colorid = os:unmarshalInt32()
  self.hairid = os:unmarshalInt32()
  self.clothid = os:unmarshalInt32()
  self.fashionDressCfgId = os:unmarshalInt32()
end
function SAddClothesColorRes:sizepolicy(size)
  return size <= 65535
end
return SAddClothesColorRes
