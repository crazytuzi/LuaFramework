local PersonalInfo = require("netio.protocol.mzm.gsp.personal.PersonalInfo")
local SEditPersonalInfoSuccess = class("SEditPersonalInfoSuccess")
SEditPersonalInfoSuccess.TYPEID = 12603651
function SEditPersonalInfoSuccess:ctor(roleId, personalInfo)
  self.id = 12603651
  self.roleId = roleId or nil
  self.personalInfo = personalInfo or PersonalInfo.new()
end
function SEditPersonalInfoSuccess:marshal(os)
  os:marshalInt64(self.roleId)
  self.personalInfo:marshal(os)
end
function SEditPersonalInfoSuccess:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.personalInfo = PersonalInfo.new()
  self.personalInfo:unmarshal(os)
end
function SEditPersonalInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SEditPersonalInfoSuccess
