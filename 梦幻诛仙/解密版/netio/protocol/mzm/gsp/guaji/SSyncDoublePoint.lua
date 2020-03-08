local SSyncDoublePoint = class("SSyncDoublePoint")
SSyncDoublePoint.TYPEID = 12591107
function SSyncDoublePoint:ctor(getingPoolPointNum, frozenPoolPointNum, switches)
  self.id = 12591107
  self.getingPoolPointNum = getingPoolPointNum or nil
  self.frozenPoolPointNum = frozenPoolPointNum or nil
  self.switches = switches or {}
end
function SSyncDoublePoint:marshal(os)
  os:marshalInt32(self.getingPoolPointNum)
  os:marshalInt32(self.frozenPoolPointNum)
  local _size_ = 0
  for _, _ in pairs(self.switches) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, _ in pairs(self.switches) do
    os:marshalInt32(k)
  end
end
function SSyncDoublePoint:unmarshal(os)
  self.getingPoolPointNum = os:unmarshalInt32()
  self.frozenPoolPointNum = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.switches[v] = v
  end
end
function SSyncDoublePoint:sizepolicy(size)
  return size <= 32
end
return SSyncDoublePoint
