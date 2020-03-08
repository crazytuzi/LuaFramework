local SLevelAwardRes = class("SLevelAwardRes")
SLevelAwardRes.TYPEID = 12593413
function SLevelAwardRes:ctor(awardedLevels, item2num)
  self.id = 12593413
  self.awardedLevels = awardedLevels or {}
  self.item2num = item2num or {}
end
function SLevelAwardRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardedLevels))
  for _, v in ipairs(self.awardedLevels) do
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
function SLevelAwardRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.awardedLevels, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.item2num[k] = v
  end
end
function SLevelAwardRes:sizepolicy(size)
  return size <= 65535
end
return SLevelAwardRes
