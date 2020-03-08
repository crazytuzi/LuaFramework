local CPetFightSetDefenseTeamReq = class("CPetFightSetDefenseTeamReq")
CPetFightSetDefenseTeamReq.TYPEID = 12590683
function CPetFightSetDefenseTeamReq:ctor(team)
  self.id = 12590683
  self.team = team or nil
end
function CPetFightSetDefenseTeamReq:marshal(os)
  os:marshalInt32(self.team)
end
function CPetFightSetDefenseTeamReq:unmarshal(os)
  self.team = os:unmarshalInt32()
end
function CPetFightSetDefenseTeamReq:sizepolicy(size)
  return size <= 65535
end
return CPetFightSetDefenseTeamReq
