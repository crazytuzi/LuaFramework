local PersonalInfo = require("netio.protocol.mzm.gsp.personal.PersonalInfo")
local SQueryPersonalInfoSuccess = class("SQueryPersonalInfoSuccess")
SQueryPersonalInfoSuccess.TYPEID = 12603649
function SQueryPersonalInfoSuccess:ctor(roleId, personalInfo)
  self.id = 12603649
  self.roleId = roleId or nil
  self.personalInfo = personalInfo or PersonalInfo.new()
end
function SQueryPersonalInfoSuccess:marshal(os)
  os:marshalInt64(self.roleId)
  self.personalInfo:marshal(os)
end
function SQueryPersonalInfoSuccess:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.personalInfo = PersonalInfo.new()
  self.personalInfo:unmarshal(os)
end
function SQueryPersonalInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SQueryPersonalInfoSuccess
