local OctetsStream = require("netio.OctetsStream")
local RoleData = class("RoleData")
function RoleData:ctor(roleid, roleName)
  self.roleid = roleid or nil
  self.roleName = roleName or nil
end
function RoleData:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.roleName)
end
function RoleData:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
end
return RoleData
