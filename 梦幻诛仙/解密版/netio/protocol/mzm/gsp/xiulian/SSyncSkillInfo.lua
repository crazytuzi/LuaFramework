local SkillBagInfo = require("netio.protocol.mzm.gsp.xiulian.SkillBagInfo")
local SSyncSkillInfo = class("SSyncSkillInfo")
SSyncSkillInfo.TYPEID = 12589570
function SSyncSkillInfo:ctor(skillBag)
  self.id = 12589570
  self.skillBag = skillBag or SkillBagInfo.new()
end
function SSyncSkillInfo:marshal(os)
  self.skillBag:marshal(os)
end
function SSyncSkillInfo:unmarshal(os)
  self.skillBag = SkillBagInfo.new()
  self.skillBag:unmarshal(os)
end
function SSyncSkillInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncSkillInfo
