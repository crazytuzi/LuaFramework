local SFabaReplaceWashSkillErrorRes = class("SFabaReplaceWashSkillErrorRes")
SFabaReplaceWashSkillErrorRes.TYPEID = 12596028
SFabaReplaceWashSkillErrorRes.ERROR_UNKNOWN = 0
SFabaReplaceWashSkillErrorRes.ERROR_NON_EXSIT = 1
SFabaReplaceWashSkillErrorRes.ERROR_FABAO_NOT_HAS_WASH_SKILL = 2
SFabaReplaceWashSkillErrorRes.ERROR_IN_CROSS = 3
function SFabaReplaceWashSkillErrorRes:ctor(retCode)
  self.id = 12596028
  self.retCode = retCode or nil
end
function SFabaReplaceWashSkillErrorRes:marshal(os)
  os:marshalInt32(self.retCode)
end
function SFabaReplaceWashSkillErrorRes:unmarshal(os)
  self.retCode = os:unmarshalInt32()
end
function SFabaReplaceWashSkillErrorRes:sizepolicy(size)
  return size <= 65535
end
return SFabaReplaceWashSkillErrorRes
