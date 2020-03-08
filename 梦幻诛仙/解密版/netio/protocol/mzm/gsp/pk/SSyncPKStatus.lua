local SSyncPKStatus = class("SSyncPKStatus")
SSyncPKStatus.TYPEID = 12619800
function SSyncPKStatus:ctor(status_set)
  self.id = 12619800
  self.status_set = status_set or {}
end
function SSyncPKStatus:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.status_set) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.status_set) do
    os:marshalInt32(k)
  end
end
function SSyncPKStatus:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.status_set[v] = v
  end
end
function SSyncPKStatus:sizepolicy(size)
  return size <= 65535
end
return SSyncPKStatus
