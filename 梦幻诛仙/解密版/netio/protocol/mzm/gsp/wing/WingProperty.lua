local OctetsStream = require("netio.OctetsStream")
local WingProperty = class("WingProperty")
function WingProperty:ctor(propertyType, propertyValue, propertyPhase)
  self.propertyType = propertyType or nil
  self.propertyValue = propertyValue or nil
  self.propertyPhase = propertyPhase or nil
end
function WingProperty:marshal(os)
  os:marshalInt32(self.propertyType)
  os:marshalInt32(self.propertyValue)
  os:marshalInt32(self.propertyPhase)
end
function WingProperty:unmarshal(os)
  self.propertyType = os:unmarshalInt32()
  self.propertyValue = os:unmarshalInt32()
  self.propertyPhase = os:unmarshalInt32()
end
return WingProperty
