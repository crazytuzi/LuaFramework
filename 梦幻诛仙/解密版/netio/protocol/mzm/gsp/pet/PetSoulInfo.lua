local OctetsStream = require("netio.OctetsStream")
local PetSoulInfo = class("PetSoulInfo")
function PetSoulInfo:ctor(pos, level, exp, propIndex)
  self.pos = pos or nil
  self.level = level or nil
  self.exp = exp or nil
  self.propIndex = propIndex or nil
end
function PetSoulInfo:marshal(os)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.level)
  os:marshalInt32(self.exp)
  os:marshalInt32(self.propIndex)
end
function PetSoulInfo:unmarshal(os)
  self.pos = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.exp = os:unmarshalInt32()
  self.propIndex = os:unmarshalInt32()
end
return PetSoulInfo
