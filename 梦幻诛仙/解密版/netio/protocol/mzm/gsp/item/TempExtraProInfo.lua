local OctetsStream = require("netio.OctetsStream")
local TempExtraProInfo = class("TempExtraProInfo")
function TempExtraProInfo:ctor(proType, proValue)
  self.proType = proType or nil
  self.proValue = proValue or nil
end
function TempExtraProInfo:marshal(os)
  os:marshalInt32(self.proType)
  os:marshalInt32(self.proValue)
end
function TempExtraProInfo:unmarshal(os)
  self.proType = os:unmarshalInt32()
  self.proValue = os:unmarshalInt32()
end
return TempExtraProInfo
