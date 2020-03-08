local GangSkillBagInfo = require("netio.protocol.mzm.gsp.gangskill.GangSkillBagInfo")
local SGangSkillLevelUpRes = class("SGangSkillLevelUpRes")
SGangSkillLevelUpRes.TYPEID = 12599297
function SGangSkillLevelUpRes:ctor(skillInfo)
  self.id = 12599297
  self.skillInfo = skillInfo or GangSkillBagInfo.new()
end
function SGangSkillLevelUpRes:marshal(os)
  self.skillInfo:marshal(os)
end
function SGangSkillLevelUpRes:unmarshal(os)
  self.skillInfo = GangSkillBagInfo.new()
  self.skillInfo:unmarshal(os)
end
function SGangSkillLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SGangSkillLevelUpRes
