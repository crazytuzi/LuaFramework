local OctetsStream = require("netio.OctetsStream")
local OpProtect = class("OpProtect")
function OpProtect:ctor(target)
  self.target = target or nil
end
function OpProtect:marshal(os)
  os:marshalInt32(self.target)
end
function OpProtect:unmarshal(os)
  self.target = os:unmarshalInt32()
end
return OpProtect
