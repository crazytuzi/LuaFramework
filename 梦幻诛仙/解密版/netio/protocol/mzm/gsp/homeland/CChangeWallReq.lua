local CChangeWallReq = class("CChangeWallReq")
CChangeWallReq.TYPEID = 12605501
function CChangeWallReq:ctor(furnitureId, furnitureUuId)
  self.id = 12605501
  self.furnitureId = furnitureId or nil
  self.furnitureUuId = furnitureUuId or nil
end
function CChangeWallReq:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt64(self.furnitureUuId)
end
function CChangeWallReq:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.furnitureUuId = os:unmarshalInt64()
end
function CChangeWallReq:sizepolicy(size)
  return size <= 65535
end
return CChangeWallReq
