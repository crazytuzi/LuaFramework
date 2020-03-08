local OctetsStream = require("netio.OctetsStream")
local PositionData = class("PositionData")
PositionData.STATE_NULL = 1
PositionData.STATE_GRABING = 2
PositionData.STATE_PROTECT = 3
function PositionData:ctor(campId, positionState)
  self.campId = campId or nil
  self.positionState = positionState or nil
end
function PositionData:marshal(os)
  os:marshalInt32(self.campId)
  os:marshalInt32(self.positionState)
end
function PositionData:unmarshal(os)
  self.campId = os:unmarshalInt32()
  self.positionState = os:unmarshalInt32()
end
return PositionData
