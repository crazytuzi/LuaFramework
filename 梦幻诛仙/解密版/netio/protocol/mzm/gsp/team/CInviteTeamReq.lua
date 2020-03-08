local CInviteTeamReq = class("CInviteTeamReq")
CInviteTeamReq.TYPEID = 12588331
function CInviteTeamReq:ctor(invitee)
  self.id = 12588331
  self.invitee = invitee or nil
end
function CInviteTeamReq:marshal(os)
  os:marshalInt64(self.invitee)
end
function CInviteTeamReq:unmarshal(os)
  self.invitee = os:unmarshalInt64()
end
function CInviteTeamReq:sizepolicy(size)
  return size <= 65535
end
return CInviteTeamReq
