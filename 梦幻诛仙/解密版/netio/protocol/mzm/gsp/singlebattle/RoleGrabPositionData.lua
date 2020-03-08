local OctetsStream = require("netio.OctetsStream")
local RoleGrabPositionData = class("RoleGrabPositionData")
function RoleGrabPositionData:ctor(count)
  self.count = count or nil
end
function RoleGrabPositionData:marshal(os)
  os:marshalInt32(self.count)
end
function RoleGrabPositionData:unmarshal(os)
  self.count = os:unmarshalInt32()
end
return RoleGrabPositionData
