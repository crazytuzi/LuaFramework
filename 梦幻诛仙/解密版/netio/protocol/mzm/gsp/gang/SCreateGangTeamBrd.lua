local GangTeam = require("netio.protocol.mzm.gsp.gang.GangTeam")
local SCreateGangTeamBrd = class("SCreateGangTeamBrd")
SCreateGangTeamBrd.TYPEID = 12589990
function SCreateGangTeamBrd:ctor(team)
  self.id = 12589990
  self.team = team or GangTeam.new()
end
function SCreateGangTeamBrd:marshal(os)
  self.team:marshal(os)
end
function SCreateGangTeamBrd:unmarshal(os)
  self.team = GangTeam.new()
  self.team:unmarshal(os)
end
function SCreateGangTeamBrd:sizepolicy(size)
  return size <= 65535
end
return SCreateGangTeamBrd
