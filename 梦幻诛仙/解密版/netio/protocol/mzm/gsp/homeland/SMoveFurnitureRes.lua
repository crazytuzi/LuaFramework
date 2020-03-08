local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
local SMoveFurnitureRes = class("SMoveFurnitureRes")
SMoveFurnitureRes.TYPEID = 12605463
function SMoveFurnitureRes:ctor(furnitureUuId, furnitureInfo)
  self.id = 12605463
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureInfo = furnitureInfo or DisplayFurnitureInfo.new()
end
function SMoveFurnitureRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  self.furnitureInfo:marshal(os)
end
function SMoveFurnitureRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureInfo = DisplayFurnitureInfo.new()
  self.furnitureInfo:unmarshal(os)
end
function SMoveFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SMoveFurnitureRes
