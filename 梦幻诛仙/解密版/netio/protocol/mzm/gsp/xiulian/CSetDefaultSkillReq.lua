local CSetDefaultSkillReq = class("CSetDefaultSkillReq")
CSetDefaultSkillReq.TYPEID = 12589574
function CSetDefaultSkillReq:ctor(skillBagId)
  self.id = 12589574
  self.skillBagId = skillBagId or nil
end
function CSetDefaultSkillReq:marshal(os)
  os:marshalInt32(self.skillBagId)
end
function CSetDefaultSkillReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
end
function CSetDefaultSkillReq:sizepolicy(size)
  return size <= 65535
end
return CSetDefaultSkillReq
