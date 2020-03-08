local SSyncTempSkillListRemove = class("SSyncTempSkillListRemove")
SSyncTempSkillListRemove.TYPEID = 12591628
function SSyncTempSkillListRemove:ctor(skillId)
  self.id = 12591628
  self.skillId = skillId or {}
end
function SSyncTempSkillListRemove:marshal(os)
  os:marshalCompactUInt32(table.getn(self.skillId))
  for _, v in ipairs(self.skillId) do
    os:marshalInt32(v)
  end
end
function SSyncTempSkillListRemove:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.skillId, v)
  end
end
function SSyncTempSkillListRemove:sizepolicy(size)
  return size <= 65535
end
return SSyncTempSkillListRemove
