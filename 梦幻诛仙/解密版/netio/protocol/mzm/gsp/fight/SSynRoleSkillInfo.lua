local SSynRoleSkillInfo = class("SSynRoleSkillInfo")
SSynRoleSkillInfo.TYPEID = 12594209
function SSynRoleSkillInfo:ctor(fight_uuid, skillMap, seq)
  self.id = 12594209
  self.fight_uuid = fight_uuid or nil
  self.skillMap = skillMap or {}
  self.seq = seq or nil
end
function SSynRoleSkillInfo:marshal(os)
  os:marshalInt64(self.fight_uuid)
  do
    local _size_ = 0
    for _, _ in pairs(self.skillMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.skillMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.seq)
end
function SSynRoleSkillInfo:unmarshal(os)
  self.fight_uuid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skillMap[k] = v
  end
  self.seq = os:unmarshalInt32()
end
function SSynRoleSkillInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleSkillInfo
