local OctetsStream = require("netio.OctetsStream")
local FreePassInfo = class("FreePassInfo")
function FreePassInfo:ctor(count, reset_time_stamp)
  self.count = count or nil
  self.reset_time_stamp = reset_time_stamp or nil
end
function FreePassInfo:marshal(os)
  os:marshalInt32(self.count)
  os:marshalInt64(self.reset_time_stamp)
end
function FreePassInfo:unmarshal(os)
  self.count = os:unmarshalInt32()
  self.reset_time_stamp = os:unmarshalInt64()
end
return FreePassInfo
