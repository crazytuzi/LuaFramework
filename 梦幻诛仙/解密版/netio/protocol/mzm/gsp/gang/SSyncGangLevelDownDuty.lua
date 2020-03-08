local SSyncGangLevelDownDuty = class("SSyncGangLevelDownDuty")
SSyncGangLevelDownDuty.TYPEID = 12589843
function SSyncGangLevelDownDuty:ctor(building2level)
  self.id = 12589843
  self.building2level = building2level or {}
end
function SSyncGangLevelDownDuty:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.building2level) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.building2level) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncGangLevelDownDuty:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.building2level[k] = v
  end
end
function SSyncGangLevelDownDuty:sizepolicy(size)
  return size <= 65535
end
return SSyncGangLevelDownDuty
