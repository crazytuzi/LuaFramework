local SSyncGangYaoCaiNumChange = class("SSyncGangYaoCaiNumChange")
SSyncGangYaoCaiNumChange.TYPEID = 12589927
function SSyncGangYaoCaiNumChange:ctor(yaoCaiMap)
  self.id = 12589927
  self.yaoCaiMap = yaoCaiMap or {}
end
function SSyncGangYaoCaiNumChange:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.yaoCaiMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.yaoCaiMap) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncGangYaoCaiNumChange:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.yaoCaiMap[k] = v
  end
end
function SSyncGangYaoCaiNumChange:sizepolicy(size)
  return size <= 65535
end
return SSyncGangYaoCaiNumChange
