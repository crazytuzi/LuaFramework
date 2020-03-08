local CInviteGangTeamRep = class("CInviteGangTeamRep")
CInviteGangTeamRep.TYPEID = 12589985
CInviteGangTeamRep.REPLY_AGREE = 0
CInviteGangTeamRep.REPLY_REFUSE = 1
function CInviteGangTeamRep:ctor(inviter, gang_teamid, reply)
  self.id = 12589985
  self.inviter = inviter or nil
  self.gang_teamid = gang_teamid or nil
  self.reply = reply or nil
end
function CInviteGangTeamRep:marshal(os)
  os:marshalInt64(self.inviter)
  os:marshalInt64(self.gang_teamid)
  os:marshalInt32(self.reply)
end
function CInviteGangTeamRep:unmarshal(os)
  self.inviter = os:unmarshalInt64()
  self.gang_teamid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CInviteGangTeamRep:sizepolicy(size)
  return size <= 65535
end
return CInviteGangTeamRep
