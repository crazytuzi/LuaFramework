local OctetsStream = require("netio.OctetsStream")
local BlessInfo = class("BlessInfo")
function BlessInfo:ctor(num, last_time)
  self.num = num or nil
  self.last_time = last_time or nil
end
function BlessInfo:marshal(os)
  os:marshalInt32(self.num)
  os:marshalInt32(self.last_time)
end
function BlessInfo:unmarshal(os)
  self.num = os:unmarshalInt32()
  self.last_time = os:unmarshalInt32()
end
return BlessInfo
