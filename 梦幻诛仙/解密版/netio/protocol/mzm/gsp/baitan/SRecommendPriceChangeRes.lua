local SRecommendPriceChangeRes = class("SRecommendPriceChangeRes")
SRecommendPriceChangeRes.TYPEID = 12584989
function SRecommendPriceChangeRes:ctor(itemId2price)
  self.id = 12584989
  self.itemId2price = itemId2price or {}
end
function SRecommendPriceChangeRes:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.itemId2price) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemId2price) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SRecommendPriceChangeRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemId2price[k] = v
  end
end
function SRecommendPriceChangeRes:sizepolicy(size)
  return size <= 65535
end
return SRecommendPriceChangeRes
