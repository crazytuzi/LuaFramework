local SSynObserveEnd = class("SSynObserveEnd")
SSynObserveEnd.TYPEID = 12594194
function SSynObserveEnd:ctor(roleids)
  self.id = 12594194
  self.roleids = roleids or {}
end
function SSynObserveEnd:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.roleids) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.roleids) do
    os:marshalInt64(k)
  end
end
function SSynObserveEnd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    self.roleids[v] = v
  end
end
function SSynObserveEnd:sizepolicy(size)
  return size <= 65535
end
return SSynObserveEnd
