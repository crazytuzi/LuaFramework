local SMapTeamDissole = class("SMapTeamDissole")
SMapTeamDissole.TYPEID = 12590856
function SMapTeamDissole:ctor(teamId)
  self.id = 12590856
  self.teamId = teamId or nil
end
function SMapTeamDissole:marshal(os)
  os:marshalInt64(self.teamId)
end
function SMapTeamDissole:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function SMapTeamDissole:sizepolicy(size)
  return size <= 65535
end
return SMapTeamDissole
