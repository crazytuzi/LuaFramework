local OctetsStream = require("netio.OctetsStream")
local RoleFloorInfo = class("RoleFloorInfo")
function RoleFloorInfo:ctor(floor, usedTime)
  self.floor = floor or nil
  self.usedTime = usedTime or nil
end
function RoleFloorInfo:marshal(os)
  os:marshalInt32(self.floor)
  os:marshalInt32(self.usedTime)
end
function RoleFloorInfo:unmarshal(os)
  self.floor = os:unmarshalInt32()
  self.usedTime = os:unmarshalInt32()
end
return RoleFloorInfo
