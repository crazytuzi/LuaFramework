local SStudySpecialSkillErrorRes = class("SStudySpecialSkillErrorRes")
SStudySpecialSkillErrorRes.TYPEID = 12609397
SStudySpecialSkillErrorRes.ERROR_DO_NOT_HAS_ITEM = 1
SStudySpecialSkillErrorRes.ERROR_HAS_THIS_SKILL = 2
SStudySpecialSkillErrorRes.ERROR_DO_NOT_HAS_OCCUPATION = 3
function SStudySpecialSkillErrorRes:ctor(ret)
  self.id = 12609397
  self.ret = ret or nil
end
function SStudySpecialSkillErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SStudySpecialSkillErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SStudySpecialSkillErrorRes:sizepolicy(size)
  return size <= 65535
end
return SStudySpecialSkillErrorRes
