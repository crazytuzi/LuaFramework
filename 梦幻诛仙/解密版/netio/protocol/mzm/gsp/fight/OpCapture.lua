local OctetsStream = require("netio.OctetsStream")
local OpCapture = class("OpCapture")
function OpCapture:ctor(target)
  self.target = target or nil
end
function OpCapture:marshal(os)
  os:marshalInt32(self.target)
end
function OpCapture:unmarshal(os)
  self.target = os:unmarshalInt32()
end
return OpCapture
