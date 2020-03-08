local SMapLeaveTeam = class("SMapLeaveTeam")
SMapLeaveTeam.TYPEID = 12590879
function SMapLeaveTeam:ctor(teamId, roleid)
  self.id = 12590879
  self.teamId = teamId or nil
  self.roleid = roleid or nil
end
function SMapLeaveTeam:marshal(os)
  os:marshalInt64(self.teamId)
  os:marshalInt64(self.roleid)
end
function SMapLeaveTeam:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  self.roleid = os:unmarshalInt64()
end
function SMapLeaveTeam:sizepolicy(size)
  return size <= 65535
end
return SMapLeaveTeam
