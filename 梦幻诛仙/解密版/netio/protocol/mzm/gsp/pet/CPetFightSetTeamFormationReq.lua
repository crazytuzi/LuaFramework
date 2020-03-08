local CPetFightSetTeamFormationReq = class("CPetFightSetTeamFormationReq")
CPetFightSetTeamFormationReq.TYPEID = 12590690
function CPetFightSetTeamFormationReq:ctor(team, formation_id)
  self.id = 12590690
  self.team = team or nil
  self.formation_id = formation_id or nil
end
function CPetFightSetTeamFormationReq:marshal(os)
  os:marshalInt32(self.team)
  os:marshalInt32(self.formation_id)
end
function CPetFightSetTeamFormationReq:unmarshal(os)
  self.team = os:unmarshalInt32()
  self.formation_id = os:unmarshalInt32()
end
function CPetFightSetTeamFormationReq:sizepolicy(size)
  return size <= 65535
end
return CPetFightSetTeamFormationReq
