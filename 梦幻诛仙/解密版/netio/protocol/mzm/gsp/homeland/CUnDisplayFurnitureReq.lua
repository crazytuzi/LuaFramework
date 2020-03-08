local CUnDisplayFurnitureReq = class("CUnDisplayFurnitureReq")
CUnDisplayFurnitureReq.TYPEID = 12605464
function CUnDisplayFurnitureReq:ctor(furnitureUuId)
  self.id = 12605464
  self.furnitureUuId = furnitureUuId or nil
end
function CUnDisplayFurnitureReq:marshal(os)
  os:marshalInt64(self.furnitureUuId)
end
function CUnDisplayFurnitureReq:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
end
function CUnDisplayFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CUnDisplayFurnitureReq
