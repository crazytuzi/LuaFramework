local SChoiceRankSkillRes = class("SChoiceRankSkillRes")
SChoiceRankSkillRes.TYPEID = 12596002
function SChoiceRankSkillRes:ctor(equiped, fabaouuid, rank, skillid)
  self.id = 12596002
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.rank = rank or nil
  self.skillid = skillid or nil
end
function SChoiceRankSkillRes:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.skillid)
end
function SChoiceRankSkillRes:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.skillid = os:unmarshalInt32()
end
function SChoiceRankSkillRes:sizepolicy(size)
  return size <= 65535
end
return SChoiceRankSkillRes
