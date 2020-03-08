local SSynAwardedRes = class("SSynAwardedRes")
SSynAwardedRes.TYPEID = 12593421
function SSynAwardedRes:ctor(awardedTimes, item2num)
  self.id = 12593421
  self.awardedTimes = awardedTimes or {}
  self.item2num = item2num or {}
end
function SSynAwardedRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardedTimes))
  for _, v in ipairs(self.awardedTimes) do
    os:marshalInt32(v)
  end
  local _size_ = 0
  for _, _ in pairs(self.item2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.item2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSynAwardedRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.awardedTimes, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2num[k] = v
  end
end
function SSynAwardedRes:sizepolicy(size)
  return size <= 65535
end
return SSynAwardedRes
