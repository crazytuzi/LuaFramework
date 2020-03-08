local SRecycleFurnitureReqRes = class("SRecycleFurnitureReqRes")
SRecycleFurnitureReqRes.TYPEID = 12605517
function SRecycleFurnitureReqRes:ctor(furnitureUuId, furnitureId, moneyType, moneyNum)
  self.id = 12605517
  self.furnitureUuId = furnitureUuId or nil
  self.furnitureId = furnitureId or nil
  self.moneyType = moneyType or nil
  self.moneyNum = moneyNum or nil
end
function SRecycleFurnitureReqRes:marshal(os)
  os:marshalInt64(self.furnitureUuId)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.moneyType)
  os:marshalInt32(self.moneyNum)
end
function SRecycleFurnitureReqRes:unmarshal(os)
  self.furnitureUuId = os:unmarshalInt64()
  self.furnitureId = os:unmarshalInt32()
  self.moneyType = os:unmarshalInt32()
  self.moneyNum = os:unmarshalInt32()
end
function SRecycleFurnitureReqRes:sizepolicy(size)
  return size <= 65535
end
return SRecycleFurnitureReqRes
