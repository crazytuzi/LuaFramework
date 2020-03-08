local SDelClothesColorRes = class("SDelClothesColorRes")
SDelClothesColorRes.TYPEID = 12597257
function SDelClothesColorRes:ctor(colorid)
  self.id = 12597257
  self.colorid = colorid or nil
end
function SDelClothesColorRes:marshal(os)
  os:marshalInt32(self.colorid)
end
function SDelClothesColorRes:unmarshal(os)
  self.colorid = os:unmarshalInt32()
end
function SDelClothesColorRes:sizepolicy(size)
  return size <= 65535
end
return SDelClothesColorRes
