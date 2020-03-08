local OctetsStream = require("netio.OctetsStream")
local FumoInfo = class("FumoInfo")
function FumoInfo:ctor(proType, addValue, timeout)
  self.proType = proType or nil
  self.addValue = addValue or nil
  self.timeout = timeout or nil
end
function FumoInfo:marshal(os)
  os:marshalInt32(self.proType)
  os:marshalInt32(self.addValue)
  os:marshalInt64(self.timeout)
end
function FumoInfo:unmarshal(os)
  self.proType = os:unmarshalInt32()
  self.addValue = os:unmarshalInt32()
  self.timeout = os:unmarshalInt64()
end
return FumoInfo
