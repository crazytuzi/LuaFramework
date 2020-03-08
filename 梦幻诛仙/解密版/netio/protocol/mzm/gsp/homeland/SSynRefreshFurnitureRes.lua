local SSynRefreshFurnitureRes = class("SSynRefreshFurnitureRes")
SSynRefreshFurnitureRes.TYPEID = 12605462
function SSynRefreshFurnitureRes:ctor(dayRefreshCount, canBuyItems)
  self.id = 12605462
  self.dayRefreshCount = dayRefreshCount or nil
  self.canBuyItems = canBuyItems or {}
end
function SSynRefreshFurnitureRes:marshal(os)
  os:marshalInt32(self.dayRefreshCount)
  local _size_ = 0
  for _, _ in pairs(self.canBuyItems) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.canBuyItems) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynRefreshFurnitureRes:unmarshal(os)
  self.dayRefreshCount = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.canBuyItems[k] = v
  end
end
function SSynRefreshFurnitureRes:sizepolicy(size)
  return size <= 65535
end
return SSynRefreshFurnitureRes
