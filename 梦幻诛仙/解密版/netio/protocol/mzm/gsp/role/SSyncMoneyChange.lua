local SSyncMoneyChange = class("SSyncMoneyChange")
SSyncMoneyChange.TYPEID = 12585995
SSyncMoneyChange.MONEY_TYPE_GOLD = 0
SSyncMoneyChange.MONEY_TYPE_SILVER = 1
SSyncMoneyChange.MONEY_TYPE_GOLD_INGOT = 2
function SSyncMoneyChange:ctor(changeMoneyMap)
  self.id = 12585995
  self.changeMoneyMap = changeMoneyMap or {}
end
function SSyncMoneyChange:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.changeMoneyMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.changeMoneyMap) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncMoneyChange:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.changeMoneyMap[k] = v
  end
end
function SSyncMoneyChange:sizepolicy(size)
  return size <= 65535
end
return SSyncMoneyChange
