local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SBrocastRobMarriageParadeEnd = class("SBrocastRobMarriageParadeEnd")
SBrocastRobMarriageParadeEnd.TYPEID = 12599856
SBrocastRobMarriageParadeEnd.YES = 1
SBrocastRobMarriageParadeEnd.NO = 2
function SBrocastRobMarriageParadeEnd:ctor(role1Info, role2Info, result)
  self.id = 12599856
  self.role1Info = role1Info or ParadeRoleInfo.new()
  self.role2Info = role2Info or ParadeRoleInfo.new()
  self.result = result or nil
end
function SBrocastRobMarriageParadeEnd:marshal(os)
  self.role1Info:marshal(os)
  self.role2Info:marshal(os)
  os:marshalInt32(self.result)
end
function SBrocastRobMarriageParadeEnd:unmarshal(os)
  self.role1Info = ParadeRoleInfo.new()
  self.role1Info:unmarshal(os)
  self.role2Info = ParadeRoleInfo.new()
  self.role2Info:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SBrocastRobMarriageParadeEnd:sizepolicy(size)
  return size <= 65535
end
return SBrocastRobMarriageParadeEnd
