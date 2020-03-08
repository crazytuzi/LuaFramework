local OctetsStream = require("netio.OctetsStream")
local RolePosition = class("RolePosition")
function RolePosition:ctor(x, y)
  self.x = x or nil
  self.y = y or nil
end
function RolePosition:marshal(os)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
end
function RolePosition:unmarshal(os)
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
end
return RolePosition
