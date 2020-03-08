local SSynAddResourceSum = class("SSynAddResourceSum")
SSynAddResourceSum.TYPEID = 12621590
function SSynAddResourceSum:ctor(add_resource_sums)
  self.id = 12621590
  self.add_resource_sums = add_resource_sums or {}
end
function SSynAddResourceSum:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.add_resource_sums) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.add_resource_sums) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SSynAddResourceSum:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.add_resource_sums[k] = v
  end
end
function SSynAddResourceSum:sizepolicy(size)
  return size <= 65535
end
return SSynAddResourceSum
