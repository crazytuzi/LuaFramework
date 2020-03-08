local SInviteGangTeamRefusedNotify = class("SInviteGangTeamRefusedNotify")
SInviteGangTeamRefusedNotify.TYPEID = 12590005
function SInviteGangTeamRefusedNotify:ctor(invitee)
  self.id = 12590005
  self.invitee = invitee or nil
end
function SInviteGangTeamRefusedNotify:marshal(os)
  os:marshalInt64(self.invitee)
end
function SInviteGangTeamRefusedNotify:unmarshal(os)
  self.invitee = os:unmarshalInt64()
end
function SInviteGangTeamRefusedNotify:sizepolicy(size)
  return size <= 65535
end
return SInviteGangTeamRefusedNotify
