local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
local SDisplayCourtYardFurnitureRes = class("SDisplayCourtYardFurnitureRes")
SDisplayCourtYardFurnitureRes.TYPEID = 12605514
function SDisplayCourtYardFurnitureRes:ctor(furnitureUuId, furnitureInfo, to_max_type, add_beautiful_value)
  self.id = 12605514
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureInfo = furnitureInfo or DisplayFurnitureInfo.new()
  self.to_max_type = to_max_type or nil
  self.add_beautiful_value = add_beautiful_value or nil
end
function SDisplayCourtYardFurnitureRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  self.furnitureInfo:marshal(os)
  os:marshalInt32(self.to_max_type)
  os:marshalInt32(self.add_beautiful_value)
end
function SDisplayCourtYardFurnitureRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureInfo = DisplayFurnitureInfo.new()
  self.furnitureInfo:unmarshal(os)
  self.to_max_type = os:unmarshalInt32()
  self.add_beautiful_value = os:unmarshalInt32()
end
function SDisplayCourtYardFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SDisplayCourtYardFurnitureRes
