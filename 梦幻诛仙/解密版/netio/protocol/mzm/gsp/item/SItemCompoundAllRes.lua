local SItemCompoundAllRes = class("SItemCompoundAllRes")
SItemCompoundAllRes.TYPEID = 12584875
function SItemCompoundAllRes:ctor(compoundItemId2Num, costItemId2Num)
  self.id = 12584875
  self.compoundItemId2Num = compoundItemId2Num or {}
  self.costItemId2Num = costItemId2Num or {}
end
function SItemCompoundAllRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.compoundItemId2Num) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.compoundItemId2Num) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.costItemId2Num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.costItemId2Num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SItemCompoundAllRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.compoundItemId2Num[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.costItemId2Num[k] = v
  end
end
function SItemCompoundAllRes:sizepolicy(size)
  return size <= 65535
end
return SItemCompoundAllRes
