local SChangeGangTeamNameBrd = class("SChangeGangTeamNameBrd")
SChangeGangTeamNameBrd.TYPEID = 12590003
function SChangeGangTeamNameBrd:ctor(teamid, name)
  self.id = 12590003
  self.teamid = teamid or nil
  self.name = name or nil
end
function SChangeGangTeamNameBrd:marshal(os)
  os:marshalInt64(self.teamid)
  os:marshalString(self.name)
end
function SChangeGangTeamNameBrd:unmarshal(os)
  self.teamid = os:unmarshalInt64()
  self.name = os:unmarshalString()
end
function SChangeGangTeamNameBrd:sizepolicy(size)
  return size <= 65535
end
return SChangeGangTeamNameBrd
