local TeamMember = require("netio.protocol.mzm.gsp.team.TeamMember")
local SNewMemberJoinTeamBrd = class("SNewMemberJoinTeamBrd")
SNewMemberJoinTeamBrd.TYPEID = 12588301
function SNewMemberJoinTeamBrd:ctor(member)
  self.id = 12588301
  self.member = member or TeamMember.new()
end
function SNewMemberJoinTeamBrd:marshal(os)
  self.member:marshal(os)
end
function SNewMemberJoinTeamBrd:unmarshal(os)
  self.member = TeamMember.new()
  self.member:unmarshal(os)
end
function SNewMemberJoinTeamBrd:sizepolicy(size)
  return size <= 65535
end
return SNewMemberJoinTeamBrd
