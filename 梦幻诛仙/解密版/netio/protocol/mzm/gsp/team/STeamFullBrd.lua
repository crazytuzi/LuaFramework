local STeamFullBrd = class("STeamFullBrd")
STeamFullBrd.TYPEID = 12588294
function STeamFullBrd:ctor(team)
  self.id = 12588294
  self.team = team or nil
end
function STeamFullBrd:marshal(os)
  os:marshalInt64(self.team)
end
function STeamFullBrd:unmarshal(os)
  self.team = os:unmarshalInt64()
end
function STeamFullBrd:sizepolicy(size)
  return size <= 65535
end
return STeamFullBrd
