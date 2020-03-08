local SJoinGangTeamRefusedNotify = class("SJoinGangTeamRefusedNotify")
SJoinGangTeamRefusedNotify.TYPEID = 12590004
function SJoinGangTeamRefusedNotify:ctor(leaderid)
  self.id = 12590004
  self.leaderid = leaderid or nil
end
function SJoinGangTeamRefusedNotify:marshal(os)
  os:marshalInt64(self.leaderid)
end
function SJoinGangTeamRefusedNotify:unmarshal(os)
  self.leaderid = os:unmarshalInt64()
end
function SJoinGangTeamRefusedNotify:sizepolicy(size)
  return size <= 65535
end
return SJoinGangTeamRefusedNotify
