local SPetFightSetDefenseTeamFail = class("SPetFightSetDefenseTeamFail")
SPetFightSetDefenseTeamFail.TYPEID = 12590684
SPetFightSetDefenseTeamFail.EMPTY_TEAM = 1
function SPetFightSetDefenseTeamFail:ctor(reason, team)
  self.id = 12590684
  self.reason = reason or nil
  self.team = team or nil
end
function SPetFightSetDefenseTeamFail:marshal(os)
  os:marshalInt32(self.reason)
  os:marshalInt32(self.team)
end
function SPetFightSetDefenseTeamFail:unmarshal(os)
  self.reason = os:unmarshalInt32()
  self.team = os:unmarshalInt32()
end
function SPetFightSetDefenseTeamFail:sizepolicy(size)
  return size <= 65535
end
return SPetFightSetDefenseTeamFail
