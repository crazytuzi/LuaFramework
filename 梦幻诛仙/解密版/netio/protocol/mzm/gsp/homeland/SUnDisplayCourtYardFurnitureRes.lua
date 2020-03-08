local SUnDisplayCourtYardFurnitureRes = class("SUnDisplayCourtYardFurnitureRes")
SUnDisplayCourtYardFurnitureRes.TYPEID = 12605513
function SUnDisplayCourtYardFurnitureRes:ctor(furnitureUuId, furnitureId, dec_beautiful)
  self.id = 12605513
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
  self.dec_beautiful = dec_beautiful or nil
end
function SUnDisplayCourtYardFurnitureRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.dec_beautiful)
end
function SUnDisplayCourtYardFurnitureRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
  self.dec_beautiful = os:unmarshalInt32()
end
function SUnDisplayCourtYardFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SUnDisplayCourtYardFurnitureRes
