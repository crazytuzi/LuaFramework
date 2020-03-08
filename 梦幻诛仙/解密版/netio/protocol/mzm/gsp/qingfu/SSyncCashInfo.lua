local SSyncCashInfo = class("SSyncCashInfo")
SSyncCashInfo.TYPEID = 12588805
SSyncCashInfo.SAVE_AMT = 1
SSyncCashInfo.TOTAL_CASH = 2
SSyncCashInfo.TOTAL_COST = 3
SSyncCashInfo.TOTAL_COST_BIND = 4
SSyncCashInfo.TOTAL_PRESENT = 5
SSyncCashInfo.TOTAL_PRESENT_BIND = 6
function SSyncCashInfo:ctor(infos)
  self.id = 12588805
  self.infos = infos or {}
end
function SSyncCashInfo:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.infos) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.infos) do
    os:marshalInt32(k)
    os:marshalInt64(v)
  end
end
function SSyncCashInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.infos[k] = v
  end
end
function SSyncCashInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncCashInfo
