local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SBrocastRobMarriageParade = class("SBrocastRobMarriageParade")
SBrocastRobMarriageParade.TYPEID = 12599847
function SBrocastRobMarriageParade:ctor(role1Info, role2Info)
  self.id = 12599847
  self.role1Info = role1Info or ParadeRoleInfo.new()
  self.role2Info = role2Info or ParadeRoleInfo.new()
end
function SBrocastRobMarriageParade:marshal(os)
  self.role1Info:marshal(os)
  self.role2Info:marshal(os)
end
function SBrocastRobMarriageParade:unmarshal(os)
  self.role1Info = ParadeRoleInfo.new()
  self.role1Info:unmarshal(os)
  self.role2Info = ParadeRoleInfo.new()
  self.role2Info:unmarshal(os)
end
function SBrocastRobMarriageParade:sizepolicy(size)
  return size <= 65535
end
return SBrocastRobMarriageParade
