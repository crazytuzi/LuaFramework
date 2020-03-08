local OctetsStream = require("netio.OctetsStream")
local GPair = class("GPair")
function GPair:ctor(key, value)
  self.key = key or nil
  self.value = value or nil
end
function GPair:marshal(os)
  os:marshalInt32(self.key)
  os:marshalInt32(self.value)
end
function GPair:unmarshal(os)
  self.key = os:unmarshalInt32()
  self.value = os:unmarshalInt32()
end
return GPair
