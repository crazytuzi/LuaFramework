local OctetsStream = require("netio.OctetsStream")
local ManualRefreshCountInfo = class("ManualRefreshCountInfo")
function ManualRefreshCountInfo:ctor(manualRefreshCount, manualRefreshCountResetTimeStamp)
  self.manualRefreshCount = manualRefreshCount or nil
  self.manualRefreshCountResetTimeStamp = manualRefreshCountResetTimeStamp or nil
end
function ManualRefreshCountInfo:marshal(os)
  os:marshalInt32(self.manualRefreshCount)
  os:marshalInt64(self.manualRefreshCountResetTimeStamp)
end
function ManualRefreshCountInfo:unmarshal(os)
  self.manualRefreshCount = os:unmarshalInt32()
  self.manualRefreshCountResetTimeStamp = os:unmarshalInt64()
end
return ManualRefreshCountInfo
