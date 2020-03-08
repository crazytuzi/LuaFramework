local SSyncYuanbaoChange = class("SSyncYuanbaoChange")
SSyncYuanbaoChange.TYPEID = 12586241
SSyncYuanbaoChange.YUANBAO_AWARD = 0
SSyncYuanbaoChange.YUANBAO_BUY = 1
SSyncYuanbaoChange.TOTAL_BUY_YUANBAO = 2
function SSyncYuanbaoChange:ctor(yuanbaoChangeMap)
  self.id = 12586241
  self.yuanbaoChangeMap = yuanbaoChangeMap or {}
end
function SSyncYuanbaoChange:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.yuanbaoChangeMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.yuanbaoChangeMap) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncYuanbaoChange:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.yuanbaoChangeMap[k] = v
  end
end
function SSyncYuanbaoChange:sizepolicy(size)
  return size <= 65535
end
return SSyncYuanbaoChange
