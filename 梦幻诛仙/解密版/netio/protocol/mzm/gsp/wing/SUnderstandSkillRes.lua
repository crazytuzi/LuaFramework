local WingSkill = require("netio.protocol.mzm.gsp.wing.WingSkill")
local ModelId2DyeId = require("netio.protocol.mzm.gsp.wing.ModelId2DyeId")
local SUnderstandSkillRes = class("SUnderstandSkillRes")
SUnderstandSkillRes.TYPEID = 12596496
function SUnderstandSkillRes:ctor(index, phase, skillIndex, skill, modelId2dyeid)
  self.id = 12596496
  self.index = index or nil
  self.phase = phase or nil
  self.skillIndex = skillIndex or nil
  self.skill = skill or WingSkill.new()
  self.modelId2dyeid = modelId2dyeid or ModelId2DyeId.new()
end
function SUnderstandSkillRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.phase)
  os:marshalInt32(self.skillIndex)
  self.skill:marshal(os)
  self.modelId2dyeid:marshal(os)
end
function SUnderstandSkillRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.phase = os:unmarshalInt32()
  self.skillIndex = os:unmarshalInt32()
  self.skill = WingSkill.new()
  self.skill:unmarshal(os)
  self.modelId2dyeid = ModelId2DyeId.new()
  self.modelId2dyeid:unmarshal(os)
end
function SUnderstandSkillRes:sizepolicy(size)
  return size <= 65535
end
return SUnderstandSkillRes
