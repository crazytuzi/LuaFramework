local CUseClothesColorReq = class("CUseClothesColorReq")
CUseClothesColorReq.TYPEID = 12597253
function CUseClothesColorReq:ctor(colorid)
  self.id = 12597253
  self.colorid = colorid or nil
end
function CUseClothesColorReq:marshal(os)
  os:marshalInt32(self.colorid)
end
function CUseClothesColorReq:unmarshal(os)
  self.colorid = os:unmarshalInt32()
end
function CUseClothesColorReq:sizepolicy(size)
  return size <= 65535
end
return CUseClothesColorReq
