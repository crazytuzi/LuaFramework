local SUnsetTargetSkillRep = class("SUnsetTargetSkillRep")
SUnsetTargetSkillRep.TYPEID = 12596544
function SUnsetTargetSkillRep:ctor(cfg_id, index)
  self.id = 12596544
  self.cfg_id = cfg_id or nil
  self.index = index or nil
end
function SUnsetTargetSkillRep:marshal(os)
  os:marshalInt32(self.cfg_id)
  os:marshalInt32(self.index)
end
function SUnsetTargetSkillRep:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SUnsetTargetSkillRep:sizepolicy(size)
  return size <= 65535
end
return SUnsetTargetSkillRep
