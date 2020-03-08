local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SBrocastRobMarriageParadeWin = class("SBrocastRobMarriageParadeWin")
SBrocastRobMarriageParadeWin.TYPEID = 12599846
function SBrocastRobMarriageParadeWin:ctor(winAttacker, role1Info, role2Info)
  self.id = 12599846
  self.winAttacker = winAttacker or ParadeRoleInfo.new()
  self.role1Info = role1Info or ParadeRoleInfo.new()
  self.role2Info = role2Info or ParadeRoleInfo.new()
end
function SBrocastRobMarriageParadeWin:marshal(os)
  self.winAttacker:marshal(os)
  self.role1Info:marshal(os)
  self.role2Info:marshal(os)
end
function SBrocastRobMarriageParadeWin:unmarshal(os)
  self.winAttacker = ParadeRoleInfo.new()
  self.winAttacker:unmarshal(os)
  self.role1Info = ParadeRoleInfo.new()
  self.role1Info:unmarshal(os)
  self.role2Info = ParadeRoleInfo.new()
  self.role2Info:unmarshal(os)
end
function SBrocastRobMarriageParadeWin:sizepolicy(size)
  return size <= 65535
end
return SBrocastRobMarriageParadeWin
