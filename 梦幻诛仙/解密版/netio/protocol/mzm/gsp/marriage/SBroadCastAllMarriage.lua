local SBroadCastAllMarriage = class("SBroadCastAllMarriage")
SBroadCastAllMarriage.TYPEID = 12599818
function SBroadCastAllMarriage:ctor(roleidA, roleidAName, roleidB, roleidBName, level, marriageCounter)
  self.id = 12599818
  self.roleidA = roleidA or nil
  self.roleidAName = roleidAName or nil
  self.roleidB = roleidB or nil
  self.roleidBName = roleidBName or nil
  self.level = level or nil
  self.marriageCounter = marriageCounter or nil
end
function SBroadCastAllMarriage:marshal(os)
  os:marshalInt64(self.roleidA)
  os:marshalString(self.roleidAName)
  os:marshalInt64(self.roleidB)
  os:marshalString(self.roleidBName)
  os:marshalInt32(self.level)
  os:marshalInt32(self.marriageCounter)
end
function SBroadCastAllMarriage:unmarshal(os)
  self.roleidA = os:unmarshalInt64()
  self.roleidAName = os:unmarshalString()
  self.roleidB = os:unmarshalInt64()
  self.roleidBName = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.marriageCounter = os:unmarshalInt32()
end
function SBroadCastAllMarriage:sizepolicy(size)
  return size <= 65535
end
return SBroadCastAllMarriage
