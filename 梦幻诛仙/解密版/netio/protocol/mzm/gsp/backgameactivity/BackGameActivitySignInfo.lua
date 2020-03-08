local OctetsStream = require("netio.OctetsStream")
local BackGameActivitySignInfo = class("BackGameActivitySignInfo")
function BackGameActivitySignInfo:ctor(sign_count, last_sign_time)
  self.sign_count = sign_count or nil
  self.last_sign_time = last_sign_time or nil
end
function BackGameActivitySignInfo:marshal(os)
  os:marshalInt32(self.sign_count)
  os:marshalInt64(self.last_sign_time)
end
function BackGameActivitySignInfo:unmarshal(os)
  self.sign_count = os:unmarshalInt32()
  self.last_sign_time = os:unmarshalInt64()
end
return BackGameActivitySignInfo
