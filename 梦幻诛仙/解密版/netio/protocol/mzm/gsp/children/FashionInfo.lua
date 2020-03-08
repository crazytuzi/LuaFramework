local OctetsStream = require("netio.OctetsStream")
local FashionInfo = class("FashionInfo")
function FashionInfo:ctor(start_time)
  self.start_time = start_time or nil
end
function FashionInfo:marshal(os)
  os:marshalInt32(self.start_time)
end
function FashionInfo:unmarshal(os)
  self.start_time = os:unmarshalInt32()
end
return FashionInfo
