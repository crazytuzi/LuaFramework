local OctetsStream = require("netio.OctetsStream")
local PetFightFormationInfo = class("PetFightFormationInfo")
function PetFightFormationInfo:ctor(level, exp)
  self.level = level or nil
  self.exp = exp or nil
end
function PetFightFormationInfo:marshal(os)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
end
function PetFightFormationInfo:unmarshal(os)
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
end
return PetFightFormationInfo
