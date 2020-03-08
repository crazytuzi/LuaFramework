local OctetsStream = require("netio.OctetsStream")
local TitleInfo = class("TitleInfo")
function TitleInfo:ctor(titleId, timeout)
  self.titleId = titleId or nil
  self.timeout = timeout or nil
end
function TitleInfo:marshal(os)
  os:marshalInt32(self.titleId)
  os:marshalInt64(self.timeout)
end
function TitleInfo:unmarshal(os)
  self.titleId = os:unmarshalInt32()
  self.timeout = os:unmarshalInt64()
end
return TitleInfo
