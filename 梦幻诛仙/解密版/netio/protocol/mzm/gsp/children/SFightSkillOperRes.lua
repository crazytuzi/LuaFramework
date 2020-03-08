local SFightSkillOperRes = class("SFightSkillOperRes")
SFightSkillOperRes.TYPEID = 12609401
function SFightSkillOperRes:ctor(childrenid, skillid, use)
  self.id = 12609401
  self.childrenid = childrenid or nil
  self.skillid = skillid or nil
  self.use = use or nil
end
function SFightSkillOperRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.skillid)
  os:marshalInt32(self.use)
end
function SFightSkillOperRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
  self.use = os:unmarshalInt32()
end
function SFightSkillOperRes:sizepolicy(size)
  return size <= 65535
end
return SFightSkillOperRes
