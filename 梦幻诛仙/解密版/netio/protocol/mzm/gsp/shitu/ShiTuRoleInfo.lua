local OctetsStream = require("netio.OctetsStream")
local ShiTuRoleInfo = class("ShiTuRoleInfo")
function ShiTuRoleInfo:ctor(roleId, roleName, gender, occupationId)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
end
function ShiTuRoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
end
function ShiTuRoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
end
return ShiTuRoleInfo
