local SFightSkillOperErrorRes = class("SFightSkillOperErrorRes")
SFightSkillOperErrorRes.TYPEID = 12609402
SFightSkillOperErrorRes.ERROR_DO_NOT_HAS_SKILL = 1
SFightSkillOperErrorRes.ERROR_SKILL_MAX = 2
SFightSkillOperErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 3
SFightSkillOperErrorRes.ERROR_UNLOCK_NEED_EQUIP_LEVEL = 4
SFightSkillOperErrorRes.ERROR_TOW_SKILLS_NEED_EQUIP_LEVEL = 5
function SFightSkillOperErrorRes:ctor(ret)
  self.id = 12609402
  self.ret = ret or nil
end
function SFightSkillOperErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SFightSkillOperErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SFightSkillOperErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFightSkillOperErrorRes
