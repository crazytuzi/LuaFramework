local CInviteTeamRep = class("CInviteTeamRep")
CInviteTeamRep.TYPEID = 12588299
CInviteTeamRep.REPLY_ACCEPT = 1
CInviteTeamRep.REPLY_REFUSE = 2
function CInviteTeamRep:ctor(inviter, sessionid, reply)
  self.id = 12588299
  self.inviter = inviter or nil
  self.sessionid = sessionid or nil
  self.reply = reply or nil
end
function CInviteTeamRep:marshal(os)
  os:marshalInt64(self.inviter)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.reply)
end
function CInviteTeamRep:unmarshal(os)
  self.inviter = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CInviteTeamRep:sizepolicy(size)
  return size <= 65535
end
return CInviteTeamRep
