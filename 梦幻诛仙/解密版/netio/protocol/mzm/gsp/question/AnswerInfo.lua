local OctetsStream = require("netio.OctetsStream")
local AnswerInfo = class("AnswerInfo")
function AnswerInfo:ctor(roleId, roleName, occupationId, gender)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.occupationId = occupationId or nil
  self.gender = gender or nil
end
function AnswerInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.gender)
end
function AnswerInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
end
return AnswerInfo
