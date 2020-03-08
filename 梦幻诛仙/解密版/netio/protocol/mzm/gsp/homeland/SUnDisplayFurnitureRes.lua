local SUnDisplayFurnitureRes = class("SUnDisplayFurnitureRes")
SUnDisplayFurnitureRes.TYPEID = 12605477
function SUnDisplayFurnitureRes:ctor(furnitureUuId, furnitureId, decFengshui)
  self.id = 12605477
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
  self.decFengshui = decFengshui or nil
end
function SUnDisplayFurnitureRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.decFengshui)
end
function SUnDisplayFurnitureRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
  self.decFengshui = os:unmarshalInt32()
end
function SUnDisplayFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SUnDisplayFurnitureRes
