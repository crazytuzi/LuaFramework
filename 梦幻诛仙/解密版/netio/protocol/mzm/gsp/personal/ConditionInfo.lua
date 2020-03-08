local OctetsStream = require("netio.OctetsStream")
local ConditionInfo = class("ConditionInfo")
function ConditionInfo:ctor(gender, minLevel, maxLevel, location)
  self.gender = gender or nil
  self.minLevel = minLevel or nil
  self.maxLevel = maxLevel or nil
  self.location = location or nil
end
function ConditionInfo:marshal(os)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.minLevel)
  os:marshalInt32(self.maxLevel)
  os:marshalInt32(self.location)
end
function ConditionInfo:unmarshal(os)
  self.gender = os:unmarshalInt32()
  self.minLevel = os:unmarshalInt32()
  self.maxLevel = os:unmarshalInt32()
  self.location = os:unmarshalInt32()
end
return ConditionInfo
