local CInviteGangTeamReq = class("CInviteGangTeamReq")
CInviteGangTeamReq.TYPEID = 12589991
function CInviteGangTeamReq:ctor(invitee)
  self.id = 12589991
  self.invitee = invitee or nil
end
function CInviteGangTeamReq:marshal(os)
  os:marshalInt64(self.invitee)
end
function CInviteGangTeamReq:unmarshal(os)
  self.invitee = os:unmarshalInt64()
end
function CInviteGangTeamReq:sizepolicy(size)
  return size <= 65535
end
return CInviteGangTeamReq
