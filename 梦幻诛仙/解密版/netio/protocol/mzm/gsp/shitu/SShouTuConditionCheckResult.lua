local SShouTuConditionCheckResult = class("SShouTuConditionCheckResult")
SShouTuConditionCheckResult.TYPEID = 12601613
function SShouTuConditionCheckResult:ctor(result)
  self.id = 12601613
  self.result = result or {}
end
function SShouTuConditionCheckResult:marshal(os)
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
function SShouTuConditionCheckResult:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.result[k] = v
  end
end
function SShouTuConditionCheckResult:sizepolicy(size)
  return size <= 65535
end
return SShouTuConditionCheckResult
