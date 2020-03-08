local SChuShiConditionCheckResult = class("SChuShiConditionCheckResult")
SChuShiConditionCheckResult.TYPEID = 12601618
function SChuShiConditionCheckResult:ctor(result)
  self.id = 12601618
  self.result = result or {}
end
function SChuShiConditionCheckResult:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.result) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.result) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SChuShiConditionCheckResult:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.result[k] = v
  end
end
function SChuShiConditionCheckResult:sizepolicy(size)
  return size <= 65535
end
return SChuShiConditionCheckResult
