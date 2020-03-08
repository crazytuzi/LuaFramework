local SLeaveTeamBrd = class("SLeaveTeamBrd")
SLeaveTeamBrd.TYPEID = 12588304
function SLeaveTeamBrd:ctor(roleid)
  self.id = 12588304
  self.roleid = roleid or nil
end
function SLeaveTeamBrd:marshal(os)
  os:marshalInt64(self.roleid)
end
function SLeaveTeamBrd:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function SLeaveTeamBrd:sizepolicy(size)
  return size <= 65535
end
return SLeaveTeamBrd
