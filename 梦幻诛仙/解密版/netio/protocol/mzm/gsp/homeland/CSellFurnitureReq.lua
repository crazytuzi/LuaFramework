local CSellFurnitureReq = class("CSellFurnitureReq")
CSellFurnitureReq.TYPEID = 12605454
function CSellFurnitureReq:ctor(furnitureUuId, furnitureId)
  self.id = 12605454
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
end
function CSellFurnitureReq:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
end
function CSellFurnitureReq:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
end
function CSellFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CSellFurnitureReq
