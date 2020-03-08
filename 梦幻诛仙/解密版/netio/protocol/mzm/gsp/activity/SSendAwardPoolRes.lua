local SSendAwardPoolRes = class("SSendAwardPoolRes")
SSendAwardPoolRes.TYPEID = 12587601
SSendAwardPoolRes.MONEY_YUANBAO = 0
SSendAwardPoolRes.MONEY_GOLD = 1
SSendAwardPoolRes.MONEY_SILVER = 2
function SSendAwardPoolRes:ctor(awardMoney, awardItems)
  self.id = 12587601
  self.awardMoney = awardMoney or {}
  self.awardItems = awardItems or {}
end
function SSendAwardPoolRes:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.awardMoney) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.awardMoney) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.awardItems) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.awardItems) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSendAwardPoolRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.awardMoney[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.awardItems[k] = v
  end
end
function SSendAwardPoolRes:sizepolicy(size)
  return size <= 65535
end
return SSendAwardPoolRes
