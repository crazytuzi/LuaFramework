local OctetsStream = require("netio.OctetsStream")
local ParadeRoleInfo = class("ParadeRoleInfo")
function ParadeRoleInfo:ctor(roleid, roleName)
  self.roleid = roleid or nil
  self.roleName = roleName or nil
end
function ParadeRoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
end
function ParadeRoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
end
return ParadeRoleInfo
