local SUseMarriageSugerItem = class("SUseMarriageSugerItem")
SUseMarriageSugerItem.TYPEID = 12584829
SUseMarriageSugerItem.BAG_NOT_FULL = 0
SUseMarriageSugerItem.BAG_FULL = 1
function SUseMarriageSugerItem:ctor(item2count, isBagFull)
  self.id = 12584829
  self.item2count = item2count or {}
  self.isBagFull = isBagFull or nil
end
function SUseMarriageSugerItem:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.item2count) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.item2count) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.isBagFull)
end
function SUseMarriageSugerItem:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2count[k] = v
  end
  self.isBagFull = os:unmarshalInt32()
end
function SUseMarriageSugerItem:sizepolicy(size)
  return size <= 65535
end
return SUseMarriageSugerItem
