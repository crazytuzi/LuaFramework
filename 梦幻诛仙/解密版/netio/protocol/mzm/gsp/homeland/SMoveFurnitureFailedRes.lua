local SMoveFurnitureFailedRes = class("SMoveFurnitureFailedRes")
SMoveFurnitureFailedRes.TYPEID = 12605498
function SMoveFurnitureFailedRes:ctor(furnitureUuId)
  self.id = 12605498
  self.furnitureUuId = furnitureUuId or nil
end
function SMoveFurnitureFailedRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
end
function SMoveFurnitureFailedRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
end
function SMoveFurnitureFailedRes:sizepolicy(size)
  return size <= 65535
end
return SMoveFurnitureFailedRes
