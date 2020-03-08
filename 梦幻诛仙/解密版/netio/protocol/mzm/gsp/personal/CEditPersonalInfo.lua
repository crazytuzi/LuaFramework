local EditPersonalInfo = require("netio.protocol.mzm.gsp.personal.EditPersonalInfo")
local CEditPersonalInfo = class("CEditPersonalInfo")
CEditPersonalInfo.TYPEID = 12603655
function CEditPersonalInfo:ctor(personalInfo)
  self.id = 12603655
  self.personalInfo = personalInfo or EditPersonalInfo.new()
end
function CEditPersonalInfo:marshal(os)
  self.personalInfo:marshal(os)
end
function CEditPersonalInfo:unmarshal(os)
  self.personalInfo = EditPersonalInfo.new()
  self.personalInfo:unmarshal(os)
end
function CEditPersonalInfo:sizepolicy(size)
  return size <= 65535
end
return CEditPersonalInfo
