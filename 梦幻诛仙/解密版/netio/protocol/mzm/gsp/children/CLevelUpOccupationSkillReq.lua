local CLevelUpOccupationSkillReq = class("CLevelUpOccupationSkillReq")
CLevelUpOccupationSkillReq.TYPEID = 12609378
function CLevelUpOccupationSkillReq:ctor(childrenid, skillid)
  self.id = 12609378
  self.childrenid = childrenid or nil
  self.skillid = skillid or nil
end
function CLevelUpOccupationSkillReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.skillid)
end
function CLevelUpOccupationSkillReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
end
function CLevelUpOccupationSkillReq:sizepolicy(size)
  return size <= 65535
end
return CLevelUpOccupationSkillReq
