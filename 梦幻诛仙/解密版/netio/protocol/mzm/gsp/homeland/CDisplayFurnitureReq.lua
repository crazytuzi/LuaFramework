local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
local CDisplayFurnitureReq = class("CDisplayFurnitureReq")
CDisplayFurnitureReq.TYPEID = 12605457
function CDisplayFurnitureReq:ctor(furnitureUuId, furnitureInfo)
  self.id = 12605457
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureInfo = furnitureInfo or DisplayFurnitureInfo.new()
end
function CDisplayFurnitureReq:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  self.furnitureInfo:marshal(os)
end
function CDisplayFurnitureReq:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureInfo = DisplayFurnitureInfo.new()
  self.furnitureInfo:unmarshal(os)
end
function CDisplayFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CDisplayFurnitureReq
