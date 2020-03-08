local SDecFurnitureRes = class("SDecFurnitureRes")
SDecFurnitureRes.TYPEID = 12605504
function SDecFurnitureRes:ctor(furnitureId, furnitureUuId, area)
  self.id = 12605504
  self.furnitureId = furnitureId or nil
  self.furnitureUuId = furnitureUuId or nil
  self.area = area or nil
end
function SDecFurnitureRes:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.area)
end
function SDecFurnitureRes:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.furnitureUuId = os:unmarshalInt64()
  self.area = os:unmarshalInt32()
end
function SDecFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SDecFurnitureRes
