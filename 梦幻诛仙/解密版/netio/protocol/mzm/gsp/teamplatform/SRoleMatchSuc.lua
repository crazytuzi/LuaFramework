local RoleInfo = require("netio.protocol.mzm.gsp.role.RoleInfo")
local SRoleMatchSuc = class("SRoleMatchSuc")
SRoleMatchSuc.TYPEID = 12593668
function SRoleMatchSuc:ctor(teamLeaderInfo)
  self.id = 12593668
  self.teamLeaderInfo = teamLeaderInfo or RoleInfo.new()
end
function SRoleMatchSuc:marshal(os)
  self.teamLeaderInfo:marshal(os)
end
function SRoleMatchSuc:unmarshal(os)
  self.teamLeaderInfo = RoleInfo.new()
  self.teamLeaderInfo:unmarshal(os)
end
function SRoleMatchSuc:sizepolicy(size)
  return size <= 65535
end
return SRoleMatchSuc
