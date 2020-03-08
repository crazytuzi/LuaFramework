local SStudyCommonSkillSkillErrorRes = class("SStudyCommonSkillSkillErrorRes")
SStudyCommonSkillSkillErrorRes.TYPEID = 12609386
SStudyCommonSkillSkillErrorRes.ERROR_DO_NOT_HAS_ITEM = 1
SStudyCommonSkillSkillErrorRes.ERROR_DO_NOT_HAS_POSITION = 2
SStudyCommonSkillSkillErrorRes.ERROR_HAS_THIS_SKILL = 3
SStudyCommonSkillSkillErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 4
function SStudyCommonSkillSkillErrorRes:ctor(ret)
  self.id = 12609386
  self.ret = ret or nil
end
function SStudyCommonSkillSkillErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SStudyCommonSkillSkillErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SStudyCommonSkillSkillErrorRes:sizepolicy(size)
  return size <= 65535
end
return SStudyCommonSkillSkillErrorRes
