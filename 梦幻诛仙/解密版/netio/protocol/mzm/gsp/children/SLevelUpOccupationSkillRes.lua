local SLevelUpOccupationSkillRes = class("SLevelUpOccupationSkillRes")
SLevelUpOccupationSkillRes.TYPEID = 12609379
function SLevelUpOccupationSkillRes:ctor(childrenid, skillid, lv)
  self.id = 12609379
  self.childrenid = childrenid or nil
  self.skillid = skillid or nil
  self.lv = lv or nil
end
function SLevelUpOccupationSkillRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.skillid)
  os:marshalInt32(self.lv)
end
function SLevelUpOccupationSkillRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
  self.lv = os:unmarshalInt32()
end
function SLevelUpOccupationSkillRes:sizepolicy(size)
  return size <= 65535
end
return SLevelUpOccupationSkillRes
