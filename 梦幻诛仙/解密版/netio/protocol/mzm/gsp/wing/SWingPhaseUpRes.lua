local SWingPhaseUpRes = class("SWingPhaseUpRes")
SWingPhaseUpRes.TYPEID = 12596483
function SWingPhaseUpRes:ctor(index, hasSkill, mainSkillId, subSkillIds)
  self.id = 12596483
  self.index = index or nil
  self.hasSkill = hasSkill or nil
  self.mainSkillId = mainSkillId or nil
  self.subSkillIds = subSkillIds or {}
end
function SWingPhaseUpRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.hasSkill)
  os:marshalInt32(self.mainSkillId)
  os:marshalCompactUInt32(table.getn(self.subSkillIds))
  for _, v in ipairs(self.subSkillIds) do
    os:marshalInt32(v)
  end
end
function SWingPhaseUpRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.hasSkill = os:unmarshalInt32()
  self.mainSkillId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.subSkillIds, v)
  end
end
function SWingPhaseUpRes:sizepolicy(size)
  return size <= 65535
end
return SWingPhaseUpRes
