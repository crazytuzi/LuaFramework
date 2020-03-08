local OctetsStream = require("netio.OctetsStream")
local SpecialControlData = class("SpecialControlData")
function SpecialControlData:ctor(actvityId, openState, endTime)
  self.actvityId = actvityId or nil
  self.openState = openState or nil
  self.endTime = endTime or nil
end
function SpecialControlData:marshal(os)
  os:marshalInt32(self.actvityId)
  os:marshalInt32(self.openState)
  os:marshalInt64(self.endTime)
end
function SpecialControlData:unmarshal(os)
  self.actvityId = os:unmarshalInt32()
  self.openState = os:unmarshalInt32()
  self.endTime = os:unmarshalInt64()
end
return SpecialControlData
