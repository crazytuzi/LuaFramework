local SPetFightSetTeamFormationSuccess = class("SPetFightSetTeamFormationSuccess")
SPetFightSetTeamFormationSuccess.TYPEID = 12590687
function SPetFightSetTeamFormationSuccess:ctor(team, formation_id)
  self.id = 12590687
  self.team = team or nil
  self.formation_id = formation_id or nil
end
function SPetFightSetTeamFormationSuccess:marshal(os)
  os:marshalInt32(self.team)
  os:marshalInt32(self.formation_id)
end
function SPetFightSetTeamFormationSuccess:unmarshal(os)
  self.team = os:unmarshalInt32()
  self.formation_id = os:unmarshalInt32()
end
function SPetFightSetTeamFormationSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetTeamFormationSuccess
