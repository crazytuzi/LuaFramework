local SUseFurnitureItemRes = class("SUseFurnitureItemRes")
SUseFurnitureItemRes.TYPEID = 12605465
function SUseFurnitureItemRes:ctor(furnitureUuId, furnitureId, area)
  self.id = 12605465
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
  self.area = area or nil
end
function SUseFurnitureItemRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.area)
end
function SUseFurnitureItemRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
  self.area = os:unmarshalInt32()
end
function SUseFurnitureItemRes:sizepolicy(size)
  return size <= 65535
end
return SUseFurnitureItemRes
