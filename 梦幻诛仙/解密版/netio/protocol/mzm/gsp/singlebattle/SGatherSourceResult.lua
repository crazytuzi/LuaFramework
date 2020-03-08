local SGatherSourceResult = class("SGatherSourceResult")
SGatherSourceResult.TYPEID = 12621592
function SGatherSourceResult:ctor(role2TotalSource)
  self.id = 12621592
  self.role2TotalSource = role2TotalSource or {}
end
function SGatherSourceResult:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.role2TotalSource) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.role2TotalSource) do
    os:marshalInt64(k)
    os:marshalInt32(v)
  end
end
function SGatherSourceResult:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.role2TotalSource[k] = v
  end
end
function SGatherSourceResult:sizepolicy(size)
  return size <= 65535
end
return SGatherSourceResult
