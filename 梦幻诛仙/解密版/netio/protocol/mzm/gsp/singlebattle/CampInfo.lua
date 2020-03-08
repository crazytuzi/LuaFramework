local OctetsStream = require("netio.OctetsStream")
local CampInfo = class("CampInfo")
function CampInfo:ctor(totalSource)
  self.totalSource = totalSource or nil
end
function CampInfo:marshal(os)
  os:marshalInt32(self.totalSource)
end
function CampInfo:unmarshal(os)
  self.totalSource = os:unmarshalInt32()
end
return CampInfo
