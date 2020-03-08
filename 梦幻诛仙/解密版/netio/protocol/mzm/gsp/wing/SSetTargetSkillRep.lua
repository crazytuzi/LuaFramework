local SSetTargetSkillRep = class("SSetTargetSkillRep")
SSetTargetSkillRep.TYPEID = 12596547
function SSetTargetSkillRep:ctor(cfg_id, index, skill_id)
  self.id = 12596547
  self.cfg_id = cfg_id or nil
  self.index = index or nil
  self.skill_id = skill_id or nil
end
function SSetTargetSkillRep:marshal(os)
  os:marshalInt32(self.cfg_id)
  os:marshalInt32(self.index)
  os:marshalInt32(self.skill_id)
end
function SSetTargetSkillRep:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.skill_id = os:unmarshalInt32()
end
function SSetTargetSkillRep:sizepolicy(size)
  return size <= 65535
end
return SSetTargetSkillRep
