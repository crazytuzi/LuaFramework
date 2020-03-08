local OctetsStream = require("netio.OctetsStream")
local RideInfo = class("RideInfo")
function RideInfo:ctor(rideCfgId, colorId)
  self.rideCfgId = rideCfgId or nil
  self.colorId = colorId or nil
end
function RideInfo:marshal(os)
  os:marshalInt32(self.rideCfgId)
  os:marshalInt32(self.colorId)
end
function RideInfo:unmarshal(os)
  self.rideCfgId = os:unmarshalInt32()
  self.colorId = os:unmarshalInt32()
end
return RideInfo
