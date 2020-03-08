local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleid, roleName)
  self.roleid = roleid or nil
  self.roleName = roleName or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
end
function RoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
end
return RoleInfo
