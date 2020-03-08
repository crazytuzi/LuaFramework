local CFabaoReplaceWashSkillReq = class("CFabaoReplaceWashSkillReq")
CFabaoReplaceWashSkillReq.TYPEID = 12596031
function CFabaoReplaceWashSkillReq:ctor(equiped, fabaouuid)
  self.id = 12596031
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
end
function CFabaoReplaceWashSkillReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
end
function CFabaoReplaceWashSkillReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
end
function CFabaoReplaceWashSkillReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoReplaceWashSkillReq
