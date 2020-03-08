local SAddFurnitureRes = class("SAddFurnitureRes")
SAddFurnitureRes.TYPEID = 12605503
function SAddFurnitureRes:ctor(furnitureId, furnitureUuId, area)
  self.id = 12605503
  self.furnitureId = furnitureId or nil
  self.furnitureUuId = furnitureUuId or nil
  self.area = area or nil
end
function SAddFurnitureRes:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.area)
end
function SAddFurnitureRes:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.furnitureUuId = os:unmarshalInt64()
  self.area = os:unmarshalInt32()
end
function SAddFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SAddFurnitureRes
