local SRemoveGangTeamMemberBrd = class("SRemoveGangTeamMemberBrd")
SRemoveGangTeamMemberBrd.TYPEID = 12590008
function SRemoveGangTeamMemberBrd:ctor(teamid, memberid)
  self.id = 12590008
  self.teamid = teamid or nil
  self.memberid = memberid or nil
end
function SRemoveGangTeamMemberBrd:marshal(os)
  os:marshalInt64(self.teamid)
  os:marshalInt64(self.memberid)
end
function SRemoveGangTeamMemberBrd:unmarshal(os)
  self.teamid = os:unmarshalInt64()
  self.memberid = os:unmarshalInt64()
end
function SRemoveGangTeamMemberBrd:sizepolicy(size)
  return size <= 65535
end
return SRemoveGangTeamMemberBrd
