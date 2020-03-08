local SBroadCastMarriage = class("SBroadCastMarriage")
SBroadCastMarriage.TYPEID = 12599814
function SBroadCastMarriage:ctor(roleidA, roleidAName, roleidB, roleidBName, level, stage)
  self.id = 12599814
  self.roleidA = roleidA or nil
  self.roleidAName = roleidAName or nil
  self.roleidB = roleidB or nil
  self.roleidBName = roleidBName or nil
  self.level = level or nil
  self.stage = stage or nil
end
function SBroadCastMarriage:marshal(os)
  os:marshalInt64(self.roleidA)
  os:marshalString(self.roleidAName)
  os:marshalInt64(self.roleidB)
  os:marshalString(self.roleidBName)
  os:marshalInt32(self.level)
  os:marshalInt32(self.stage)
end
function SBroadCastMarriage:unmarshal(os)
  self.roleidA = os:unmarshalInt64()
  self.roleidAName = os:unmarshalString()
  self.roleidB = os:unmarshalInt64()
  self.roleidBName = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
end
function SBroadCastMarriage:sizepolicy(size)
  return size <= 65535
end
return SBroadCastMarriage
