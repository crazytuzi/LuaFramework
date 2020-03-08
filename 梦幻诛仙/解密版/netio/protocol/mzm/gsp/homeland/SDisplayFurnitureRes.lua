local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
local SDisplayFurnitureRes = class("SDisplayFurnitureRes")
SDisplayFurnitureRes.TYPEID = 12605483
function SDisplayFurnitureRes:ctor(furnitureUuId, furnitureInfo, tomaxtype, addFengshui)
  self.id = 12605483
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureInfo = furnitureInfo or DisplayFurnitureInfo.new()
  self.tomaxtype = tomaxtype or nil
  self.addFengshui = addFengshui or nil
end
function SDisplayFurnitureRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  self.furnitureInfo:marshal(os)
  os:marshalInt32(self.tomaxtype)
  os:marshalInt32(self.addFengshui)
end
function SDisplayFurnitureRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureInfo = DisplayFurnitureInfo.new()
  self.furnitureInfo:unmarshal(os)
  self.tomaxtype = os:unmarshalInt32()
  self.addFengshui = os:unmarshalInt32()
end
function SDisplayFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SDisplayFurnitureRes
