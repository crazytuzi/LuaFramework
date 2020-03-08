local SChoiceRankSkillErrorRes = class("SChoiceRankSkillErrorRes")
SChoiceRankSkillErrorRes.TYPEID = 12596022
SChoiceRankSkillErrorRes.ERROR_UNKNOWN = 1
SChoiceRankSkillErrorRes.ERROR_CFG_NON_EXSIT = 2
SChoiceRankSkillErrorRes.ERROR_FABAO_CHOISE_SKILL_ERROR = 3
SChoiceRankSkillErrorRes.ERROR_FABAO_NEXT_RANK_ERROR = 4
SChoiceRankSkillErrorRes.ERROR_IN_CROSS = 5
function SChoiceRankSkillErrorRes:ctor(resultcode)
  self.id = 12596022
  self.resultcode = resultcode or nil
end
function SChoiceRankSkillErrorRes:marshal(os)
  os:marshalInt32(self.resultcode)
end
function SChoiceRankSkillErrorRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
end
function SChoiceRankSkillErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChoiceRankSkillErrorRes
