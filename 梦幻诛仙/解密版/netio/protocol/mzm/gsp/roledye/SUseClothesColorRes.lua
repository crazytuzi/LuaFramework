local SUseClothesColorRes = class("SUseClothesColorRes")
SUseClothesColorRes.TYPEID = 12597258
function SUseClothesColorRes:ctor(colorid)
  self.id = 12597258
  self.colorid = colorid or nil
end
function SUseClothesColorRes:marshal(os)
  os:marshalInt32(self.colorid)
end
function SUseClothesColorRes:unmarshal(os)
  self.colorid = os:unmarshalInt32()
end
function SUseClothesColorRes:sizepolicy(size)
  return size <= 65535
end
return SUseClothesColorRes
