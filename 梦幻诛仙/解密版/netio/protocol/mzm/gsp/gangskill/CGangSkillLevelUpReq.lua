local CGangSkillLevelUpReq = class("CGangSkillLevelUpReq")
CGangSkillLevelUpReq.TYPEID = 12599300
function CGangSkillLevelUpReq:ctor(skillid)
  self.id = 12599300
  self.skillid = skillid or nil
end
function CGangSkillLevelUpReq:marshal(os)
  os:marshalInt32(self.skillid)
end
function CGangSkillLevelUpReq:unmarshal(os)
  self.skillid = os:unmarshalInt32()
end
function CGangSkillLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CGangSkillLevelUpReq
