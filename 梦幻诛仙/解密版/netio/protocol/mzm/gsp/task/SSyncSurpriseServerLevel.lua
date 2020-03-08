local SSyncSurpriseServerLevel = class("SSyncSurpriseServerLevel")
SSyncSurpriseServerLevel.TYPEID = 12592160
function SSyncSurpriseServerLevel:ctor(level2startTime)
  self.id = 12592160
  self.level2startTime = level2startTime or {}
end
function SSyncSurpriseServerLevel:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.level2startTime) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.level2startTime) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncSurpriseServerLevel:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.level2startTime[k] = v
  end
end
function SSyncSurpriseServerLevel:sizepolicy(size)
  return size <= 65535
end
return SSyncSurpriseServerLevel
