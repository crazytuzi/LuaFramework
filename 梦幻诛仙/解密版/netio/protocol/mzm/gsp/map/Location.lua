local OctetsStream = require("netio.OctetsStream")
local Location = class("Location")
function Location:ctor(x, y)
  self.x = x or nil
  self.y = y or nil
end
function Location:marshal(os)
  os:marshalInt32(self.x)
  os:marshalInt32(self.y)
end
function Location:unmarshal(os)
  self.x = os:unmarshalInt32()
  self.y = os:unmarshalInt32()
end
return Location
