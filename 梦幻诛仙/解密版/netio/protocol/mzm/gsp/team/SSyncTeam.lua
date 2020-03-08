local Team = require("netio.protocol.mzm.gsp.team.Team")
local SSyncTeam = class("SSyncTeam")
SSyncTeam.TYPEID = 12588305
function SSyncTeam:ctor(team)
  self.id = 12588305
  self.team = team or Team.new()
end
function SSyncTeam:marshal(os)
  self.team:marshal(os)
end
function SSyncTeam:unmarshal(os)
  self.team = Team.new()
  self.team:unmarshal(os)
end
function SSyncTeam:sizepolicy(size)
  return size <= 65535
end
return SSyncTeam
