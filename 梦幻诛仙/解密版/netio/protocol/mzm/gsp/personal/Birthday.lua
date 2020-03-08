local OctetsStream = require("netio.OctetsStream")
local Birthday = class("Birthday")
function Birthday:ctor(month, day)
  self.month = month or nil
  self.day = day or nil
end
function Birthday:marshal(os)
  os:marshalInt32(self.month)
  os:marshalInt32(self.day)
end
function Birthday:unmarshal(os)
  self.month = os:unmarshalInt32()
  self.day = os:unmarshalInt32()
end
return Birthday
