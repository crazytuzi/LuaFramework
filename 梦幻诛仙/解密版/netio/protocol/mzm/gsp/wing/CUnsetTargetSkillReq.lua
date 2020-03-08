local CUnsetTargetSkillReq = class("CUnsetTargetSkillReq")
CUnsetTargetSkillReq.TYPEID = 12596546
function CUnsetTargetSkillReq:ctor(cfg_id, index)
  self.id = 12596546
  self.cfg_id = cfg_id or nil
  self.index = index or nil
end
function CUnsetTargetSkillReq:marshal(os)
  os:marshalInt32(self.cfg_id)
  os:marshalInt32(self.index)
end
function CUnsetTargetSkillReq:unmarshal(os)
  self.cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CUnsetTargetSkillReq:sizepolicy(size)
  return size <= 65535
end
return CUnsetTargetSkillReq
