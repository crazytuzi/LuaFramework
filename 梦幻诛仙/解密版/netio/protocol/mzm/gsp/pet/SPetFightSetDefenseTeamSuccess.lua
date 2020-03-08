local SPetFightSetDefenseTeamSuccess = class("SPetFightSetDefenseTeamSuccess")
SPetFightSetDefenseTeamSuccess.TYPEID = 12590699
function SPetFightSetDefenseTeamSuccess:ctor(team)
  self.id = 12590699
  self.team = team or nil
end
function SPetFightSetDefenseTeamSuccess:marshal(os)
  os:marshalInt32(self.team)
end
function SPetFightSetDefenseTeamSuccess:unmarshal(os)
  self.team = os:unmarshalInt32()
end
function SPetFightSetDefenseTeamSuccess:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetDefenseTeamSuccess
