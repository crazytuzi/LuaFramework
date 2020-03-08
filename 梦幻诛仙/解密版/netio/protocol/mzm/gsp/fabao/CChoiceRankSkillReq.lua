local CChoiceRankSkillReq = class("CChoiceRankSkillReq")
CChoiceRankSkillReq.TYPEID = 12596004
function CChoiceRankSkillReq:ctor(equiped, fabaouuid, skillid)
  self.id = 12596004
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.skillid = skillid or nil
end
function CChoiceRankSkillReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.skillid)
end
function CChoiceRankSkillReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
end
function CChoiceRankSkillReq:sizepolicy(size)
  return size <= 65535
end
return CChoiceRankSkillReq
