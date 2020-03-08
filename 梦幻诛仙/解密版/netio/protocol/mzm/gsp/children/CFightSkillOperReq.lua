local CFightSkillOperReq = class("CFightSkillOperReq")
CFightSkillOperReq.TYPEID = 12609403
CFightSkillOperReq.USE = 1
CFightSkillOperReq.UN_USE = 2
function CFightSkillOperReq:ctor(childrenid, skillid, use)
  self.id = 12609403
  self.childrenid = childrenid or nil
  self.skillid = skillid or nil
  self.use = use or nil
end
function CFightSkillOperReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.skillid)
  os:marshalInt32(self.use)
end
function CFightSkillOperReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.skillid = os:unmarshalInt32()
  self.use = os:unmarshalInt32()
end
function CFightSkillOperReq:sizepolicy(size)
  return size <= 65535
end
return CFightSkillOperReq
