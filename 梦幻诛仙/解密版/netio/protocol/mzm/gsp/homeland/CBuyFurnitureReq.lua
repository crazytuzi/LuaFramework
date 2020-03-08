local CBuyFurnitureReq = class("CBuyFurnitureReq")
CBuyFurnitureReq.TYPEID = 12605451
function CBuyFurnitureReq:ctor(furnitureId, count)
  self.id = 12605451
  self.furnitureId = furnitureId or nil
  self.count = count or nil
end
function CBuyFurnitureReq:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.count)
end
function CBuyFurnitureReq:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function CBuyFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CBuyFurnitureReq
