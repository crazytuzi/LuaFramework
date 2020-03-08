local SRandomSkillRes = class("SRandomSkillRes")
SRandomSkillRes.TYPEID = 12596498
function SRandomSkillRes:ctor(index, mainSkillId, subSkillIds)
  self.id = 12596498
  self.index = index or nil
  self.mainSkillId = mainSkillId or nil
  self.subSkillIds = subSkillIds or {}
end
function SRandomSkillRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.mainSkillId)
  os:marshalCompactUInt32(table.getn(self.subSkillIds))
  for _, v in ipairs(self.subSkillIds) do
    os:marshalInt32(v)
  end
end
function SRandomSkillRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.mainSkillId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.subSkillIds, v)
  end
end
function SRandomSkillRes:sizepolicy(size)
  return size <= 65535
end
return SRandomSkillRes
