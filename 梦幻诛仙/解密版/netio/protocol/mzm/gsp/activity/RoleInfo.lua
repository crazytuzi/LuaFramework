local OctetsStream = require("netio.OctetsStream")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(roleName)
  self.roleName = roleName or nil
end
function RoleInfo:marshal(os)
  os:marshalString(self.roleName)
end
function RoleInfo:unmarshal(os)
  self.roleName = os:unmarshalString()
end
return RoleInfo
