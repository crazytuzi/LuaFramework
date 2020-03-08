local STeamEndFight = class("STeamEndFight")
STeamEndFight.TYPEID = 12590891
function STeamEndFight:ctor(teamId)
  self.id = 12590891
  self.teamId = teamId or nil
end
function STeamEndFight:marshal(os)
  os:marshalInt64(self.teamId)
end
function STeamEndFight:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function STeamEndFight:sizepolicy(size)
  return size <= 65535
end
return STeamEndFight
