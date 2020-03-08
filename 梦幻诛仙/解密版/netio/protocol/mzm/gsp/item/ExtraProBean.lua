local OctetsStream = require("netio.OctetsStream")
local ExtraProBean = class("ExtraProBean")
function ExtraProBean:ctor(proType, proValue, islock)
  self.proType = proType or nil
  self.proValue = proValue or nil
  self.islock = islock or nil
end
function ExtraProBean:marshal(os)
  os:marshalInt32(self.proType)
  os:marshalInt32(self.proValue)
  os:marshalInt32(self.islock)
end
function ExtraProBean:unmarshal(os)
  self.proType = os:unmarshalInt32()
  self.proValue = os:unmarshalInt32()
  self.islock = os:unmarshalInt32()
end
return ExtraProBean
