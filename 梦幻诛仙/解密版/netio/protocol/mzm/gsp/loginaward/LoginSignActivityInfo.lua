local OctetsStream = require("netio.OctetsStream")
local LoginSignActivityInfo = class("LoginSignActivityInfo")
function LoginSignActivityInfo:ctor(sortid, last_time, start_time)
  self.sortid = sortid or nil
  self.last_time = last_time or nil
  self.start_time = start_time or nil
end
function LoginSignActivityInfo:marshal(os)
  os:marshalInt32(self.sortid)
  os:marshalInt32(self.last_time)
  os:marshalInt32(self.start_time)
end
function LoginSignActivityInfo:unmarshal(os)
  self.sortid = os:unmarshalInt32()
  self.last_time = os:unmarshalInt32()
  self.start_time = os:unmarshalInt32()
end
return LoginSignActivityInfo
