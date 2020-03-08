local OctetsStream = require("netio.OctetsStream")
local ParadeRoleInfo = class("ParadeRoleInfo")
function ParadeRoleInfo:ctor(roleId, roleName)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
end
function ParadeRoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
end
function ParadeRoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
end
return ParadeRoleInfo
