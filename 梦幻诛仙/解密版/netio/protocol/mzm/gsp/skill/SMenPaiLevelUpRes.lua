local MenPaiSkillBagInfo = require("netio.protocol.mzm.gsp.skill.MenPaiSkillBagInfo")
local SMenPaiLevelUpRes = class("SMenPaiLevelUpRes")
SMenPaiLevelUpRes.TYPEID = 12591620
function SMenPaiLevelUpRes:ctor(skillBagInfo, useSilver)
  self.id = 12591620
  self.skillBagInfo = skillBagInfo or MenPaiSkillBagInfo.new()
  self.useSilver = useSilver or nil
end
function SMenPaiLevelUpRes:marshal(os)
  self.skillBagInfo:marshal(os)
  os:marshalInt32(self.useSilver)
end
function SMenPaiLevelUpRes:unmarshal(os)
  self.skillBagInfo = MenPaiSkillBagInfo.new()
  self.skillBagInfo:unmarshal(os)
  self.useSilver = os:unmarshalInt32()
end
function SMenPaiLevelUpRes:sizepolicy(size)
  return size <= 65535
end
return SMenPaiLevelUpRes
