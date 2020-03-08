local SBuyFurnitureFailedRes = class("SBuyFurnitureFailedRes")
SBuyFurnitureFailedRes.TYPEID = 12605497
function SBuyFurnitureFailedRes:ctor(furnitureId, buyNum, restCanBuyNum)
  self.id = 12605497
  self.furnitureId = furnitureId or nil
  self.buyNum = buyNum or nil
  self.restCanBuyNum = restCanBuyNum or nil
end
function SBuyFurnitureFailedRes:marshal(os)
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.buyNum)
  os:marshalInt32(self.restCanBuyNum)
end
function SBuyFurnitureFailedRes:unmarshal(os)
  self.furnitureId = os:unmarshalInt32()
  self.buyNum = os:unmarshalInt32()
  self.restCanBuyNum = os:unmarshalInt32()
end
function SBuyFurnitureFailedRes:sizepolicy(size)
  return size <= 65535
end
return SBuyFurnitureFailedRes
