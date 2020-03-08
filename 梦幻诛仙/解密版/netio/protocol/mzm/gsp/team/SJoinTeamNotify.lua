local Team = require("netio.protocol.mzm.gsp.team.Team")
local SJoinTeamNotify = class("SJoinTeamNotify")
SJoinTeamNotify.TYPEID = 12588291
function SJoinTeamNotify:ctor(team)
  self.id = 12588291
  self.team = team or Team.new()
end
function SJoinTeamNotify:marshal(os)
  self.team:marshal(os)
end
function SJoinTeamNotify:unmarshal(os)
  self.team = Team.new()
  self.team:unmarshal(os)
end
function SJoinTeamNotify:sizepolicy(size)
  return size <= 65535
end
return SJoinTeamNotify
