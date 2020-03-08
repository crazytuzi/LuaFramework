local SynLimitTimeActivityOpened = class("SynLimitTimeActivityOpened")
SynLimitTimeActivityOpened.TYPEID = 12587560
function SynLimitTimeActivityOpened:ctor(activityids)
  self.id = 12587560
  self.activityids = activityids or {}
end
function SynLimitTimeActivityOpened:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.activityids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.activityids) do
    os:marshalInt32(k)
  end
end
function SynLimitTimeActivityOpened:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.activityids[v] = v
  end
end
function SynLimitTimeActivityOpened:sizepolicy(size)
  return size <= 65535
end
return SynLimitTimeActivityOpened
