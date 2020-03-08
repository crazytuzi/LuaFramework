local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleid, rolename)
  self.roleid = roleid or nil
  self.rolename = rolename or nil
end
function RoleInfo:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.rolename)
end
function RoleInfo:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.rolename = os:unmarshalString()
end
return RoleInfo
