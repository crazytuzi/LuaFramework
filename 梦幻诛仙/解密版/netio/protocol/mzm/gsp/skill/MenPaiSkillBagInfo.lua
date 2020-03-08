local OctetsStream = require("netio.OctetsStream")
local MenPaiSkillBagInfo = class("MenPaiSkillBagInfo")
function MenPaiSkillBagInfo:ctor(skillbagid, level)
  self.skillbagid = skillbagid or nil
  self.level = level or nil
end
function MenPaiSkillBagInfo:marshal(os)
  os:marshalInt32(self.skillbagid)
  os:marshalInt32(self.level)
end
function MenPaiSkillBagInfo:unmarshal(os)
  self.skillbagid = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
end
return MenPaiSkillBagInfo
