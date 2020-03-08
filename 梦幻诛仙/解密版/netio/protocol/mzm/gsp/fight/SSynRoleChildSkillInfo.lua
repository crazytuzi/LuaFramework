local SSynRoleChildSkillInfo = class("SSynRoleChildSkillInfo")
SSynRoleChildSkillInfo.TYPEID = 12594213
function SSynRoleChildSkillInfo:ctor(fight_uuid, childrenUuid, skillMap, seq)
  self.id = 12594213
  self.fight_uuid = fight_uuid or nil
  self.childrenUuid = childrenUuid or nil
  self.skillMap = skillMap or {}
  self.seq = seq or nil
end
function SSynRoleChildSkillInfo:marshal(os)
  os:marshalInt64(self.fight_uuid)
  os:marshalInt64(self.childrenUuid)
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
function SSynRoleChildSkillInfo:unmarshal(os)
  self.fight_uuid = os:unmarshalInt64()
  self.childrenUuid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.skillMap[k] = v
  end
  self.seq = os:unmarshalInt32()
end
function SSynRoleChildSkillInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleChildSkillInfo
