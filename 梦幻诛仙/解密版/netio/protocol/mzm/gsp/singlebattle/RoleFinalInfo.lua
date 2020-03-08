local OctetsStream = require("netio.OctetsStream")
local RoleFinalInfo = class("RoleFinalInfo")
function RoleFinalInfo:ctor(point, killCount, dieCount)
  self.point = point or nil
  self.killCount = killCount or nil
  self.dieCount = dieCount or nil
end
function RoleFinalInfo:marshal(os)
  os:marshalInt32(self.point)
  os:marshalInt32(self.killCount)
  os:marshalInt32(self.dieCount)
end
function RoleFinalInfo:unmarshal(os)
  self.point = os:unmarshalInt32()
  self.killCount = os:unmarshalInt32()
  self.dieCount = os:unmarshalInt32()
end
return RoleFinalInfo
