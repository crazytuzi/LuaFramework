local SSyncSelfKillMonster = class("SSyncSelfKillMonster")
SSyncSelfKillMonster.TYPEID = 12613640
function SSyncSelfKillMonster:ctor(goal_times, monsters)
  self.id = 12613640
  self.goal_times = goal_times or nil
  self.monsters = monsters or {}
end
function SSyncSelfKillMonster:marshal(os)
  os:marshalInt32(self.goal_times)
  local _size_ = 0
  for _, _ in pairs(self.monsters) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.monsters) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncSelfKillMonster:unmarshal(os)
  self.goal_times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.monsters[k] = v
  end
end
function SSyncSelfKillMonster:sizepolicy(size)
  return size <= 65535
end
return SSyncSelfKillMonster
