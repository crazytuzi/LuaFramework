local SChangeWallRes = class("SChangeWallRes")
SChangeWallRes.TYPEID = 12605500
function SChangeWallRes:ctor(furnitureId, furnitureUuId, unfurnitureUuId, unfurnitureId, changeFengshui)
  self.id = 12605500
  self.furnitureId = furnitureId or nil
  self.furnitureUuId = furnitureUuId or nil
  self.unfurnitureUuId = unfurnitureUuId or nil
  self.unfurnitureId = unfurnitureId or nil
  self.changeFengshui = changeFengshui or nil
end
function SChangeWallRes:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt64(self.unfurnitureUuId)
  os:marshalInt32(self.unfurnitureId)
  os:marshalInt32(self.changeFengshui)
end
function SChangeWallRes:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.furnitureUuId = os:unmarshalInt64()
  self.unfurnitureUuId = os:unmarshalInt64()
  self.unfurnitureId = os:unmarshalInt32()
  self.changeFengshui = os:unmarshalInt32()
end
function SChangeWallRes:sizepolicy(size)
  return size <= 65535
end
return SChangeWallRes
