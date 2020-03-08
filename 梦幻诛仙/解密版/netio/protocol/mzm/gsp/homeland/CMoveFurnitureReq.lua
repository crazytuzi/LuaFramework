local DisplayFurnitureInfo = require("netio.protocol.mzm.gsp.homeland.DisplayFurnitureInfo")
local CMoveFurnitureReq = class("CMoveFurnitureReq")
CMoveFurnitureReq.TYPEID = 12605484
function CMoveFurnitureReq:ctor(furnitureUuId, furnitureInfo)
  self.id = 12605484
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureInfo = furnitureInfo or DisplayFurnitureInfo.new()
end
function CMoveFurnitureReq:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  self.furnitureInfo:marshal(os)
end
function CMoveFurnitureReq:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureInfo = DisplayFurnitureInfo.new()
  self.furnitureInfo:unmarshal(os)
end
function CMoveFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CMoveFurnitureReq
