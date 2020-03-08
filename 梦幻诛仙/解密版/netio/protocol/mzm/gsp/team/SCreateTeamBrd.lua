local Team = require("netio.protocol.mzm.gsp.team.Team")
local SCreateTeamBrd = class("SCreateTeamBrd")
SCreateTeamBrd.TYPEID = 12588300
function SCreateTeamBrd:ctor(team)
  self.id = 12588300
  self.team = team or Team.new()
end
function SCreateTeamBrd:marshal(os)
  self.team:marshal(os)
end
function SCreateTeamBrd:unmarshal(os)
  self.team = Team.new()
  self.team:unmarshal(os)
end
function SCreateTeamBrd:sizepolicy(size)
  return size <= 65535
end
return SCreateTeamBrd
