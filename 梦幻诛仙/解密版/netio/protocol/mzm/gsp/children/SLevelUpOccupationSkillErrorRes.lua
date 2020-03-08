local SLevelUpOccupationSkillErrorRes = class("SLevelUpOccupationSkillErrorRes")
SLevelUpOccupationSkillErrorRes.TYPEID = 12609377
SLevelUpOccupationSkillErrorRes.ERROR_DO_NOT_HAS_SKILL = 1
SLevelUpOccupationSkillErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 2
SLevelUpOccupationSkillErrorRes.ERROR_ITEM_NOT_ENOUGH = 3
SLevelUpOccupationSkillErrorRes.ERROR_SKILL_TO_MAX_LEVEL = 4
SLevelUpOccupationSkillErrorRes.ERROR_SKILL_NEED_EQUIP_LEVEL = 5
function SLevelUpOccupationSkillErrorRes:ctor(ret)
  self.id = 12609377
  self.ret = ret or nil
end
function SLevelUpOccupationSkillErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SLevelUpOccupationSkillErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SLevelUpOccupationSkillErrorRes:sizepolicy(size)
  return size <= 65535
end
return SLevelUpOccupationSkillErrorRes
