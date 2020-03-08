local SSyncKillBossCountBrd = class("SSyncKillBossCountBrd")
SSyncKillBossCountBrd.TYPEID = 12613650
function SSyncKillBossCountBrd:ctor(boss2count)
  self.id = 12613650
  self.boss2count = boss2count or {}
end
function SSyncKillBossCountBrd:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.boss2count) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.boss2count) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncKillBossCountBrd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.boss2count[k] = v
  end
end
function SSyncKillBossCountBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncKillBossCountBrd
