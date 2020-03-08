local OctetsStream = require("netio.OctetsStream")
local WatchmoonState = class("WatchmoonState")
function WatchmoonState:ctor(count, canWatchMoon)
  self.count = count or nil
  self.canWatchMoon = canWatchMoon or nil
end
function WatchmoonState:marshal(os)
  os:marshalInt32(self.count)
  os:marshalUInt8(self.canWatchMoon)
end
function WatchmoonState:unmarshal(os)
  self.count = os:unmarshalInt32()
  self.canWatchMoon = os:unmarshalUInt8()
end
return WatchmoonState
