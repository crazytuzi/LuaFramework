local STeamStartFight = class("STeamStartFight")
STeamStartFight.TYPEID = 12590895
function STeamStartFight:ctor(teamId)
  self.id = 12590895
  self.teamId = teamId or nil
end
function STeamStartFight:marshal(os)
  os:marshalInt64(self.teamId)
end
function STeamStartFight:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function STeamStartFight:sizepolicy(size)
  return size <= 65535
end
return STeamStartFight
