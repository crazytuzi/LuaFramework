local SPetFightSetTeamFormationFail = class("SPetFightSetTeamFormationFail")
SPetFightSetTeamFormationFail.TYPEID = 12590697
SPetFightSetTeamFormationFail.FORMATION_NOT_AVAILABLE = 1
function SPetFightSetTeamFormationFail:ctor(reason, team, formation_id)
  self.id = 12590697
  self.reason = reason or nil
  self.team = team or nil
  self.formation_id = formation_id or nil
end
function SPetFightSetTeamFormationFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.team)
  os:marshalInt32(self.formation_id)
end
function SPetFightSetTeamFormationFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.team = os:unmarshalInt32()
  self.formation_id = os:unmarshalInt32()
end
function SPetFightSetTeamFormationFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetTeamFormationFail
