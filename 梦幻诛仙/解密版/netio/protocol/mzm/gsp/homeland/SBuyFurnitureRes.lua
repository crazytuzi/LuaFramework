local SBuyFurnitureRes = class("SBuyFurnitureRes")
SBuyFurnitureRes.TYPEID = 12605493
function SBuyFurnitureRes:ctor(furnitureUuIds, furnitureId, buyNum, restCanBuyNum, moneyType, moneyNum, restFreshNum)
  self.id = 12605493
  self.furnitureUuIds = furnitureUuIds or {}
  self.furnitureId = furnitureId or nil
  self.buyNum = buyNum or nil
  self.restCanBuyNum = restCanBuyNum or nil
  self.moneyType = moneyType or nil
  self.moneyNum = moneyNum or nil
  self.restFreshNum = restFreshNum or nil
end
function SBuyFurnitureRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.furnitureUuIds) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.furnitureUuIds) do
      os:marshalInt64(k)
    end
  end
  os:marshalInt32(self.furnitureId)
  os:marshalInt32(self.buyNum)
  os:marshalInt32(self.restCanBuyNum)
  os:marshalInt32(self.moneyType)
  os:marshalInt32(self.moneyNum)
  os:marshalInt32(self.restFreshNum)
end
function SBuyFurnitureRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.furnitureUuIds[v] = v
  end
  self.furnitureId = os:unmarshalInt32()
  self.buyNum = os:unmarshalInt32()
  self.restCanBuyNum = os:unmarshalInt32()
  self.moneyType = os:unmarshalInt32()
  self.moneyNum = os:unmarshalInt32()
  self.restFreshNum = os:unmarshalInt32()
end
function SBuyFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SBuyFurnitureRes
