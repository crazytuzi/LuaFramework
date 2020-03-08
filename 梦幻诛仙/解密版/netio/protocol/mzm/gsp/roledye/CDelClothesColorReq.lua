local CDelClothesColorReq = class("CDelClothesColorReq")
CDelClothesColorReq.TYPEID = 12597252
function CDelClothesColorReq:ctor(colorid)
  self.id = 12597252
  self.colorid = colorid or nil
end
function CDelClothesColorReq:marshal(os)
  os:marshalInt32(self.colorid)
end
function CDelClothesColorReq:unmarshal(os)
  self.colorid = os:unmarshalInt32()
end
function CDelClothesColorReq:sizepolicy(size)
  return size <= 65535
end
return CDelClothesColorReq
