local CRecycleFurnitureReq = class("CRecycleFurnitureReq")
CRecycleFurnitureReq.TYPEID = 12605518
function CRecycleFurnitureReq:ctor(furnitureUuId, furnitureId)
  self.id = 12605518
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
end
function CRecycleFurnitureReq:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
end
function CRecycleFurnitureReq:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
end
function CRecycleFurnitureReq:sizepolicy(size)
  return size <= 65535
end
return CRecycleFurnitureReq
