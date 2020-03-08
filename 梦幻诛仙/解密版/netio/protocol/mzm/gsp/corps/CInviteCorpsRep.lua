local CInviteCorpsRep = class("CInviteCorpsRep")
CInviteCorpsRep.TYPEID = 12617474
CInviteCorpsRep.REPLY_ACCEPT = 1
CInviteCorpsRep.REPLY_REFUSE = 2
function CInviteCorpsRep:ctor(inviter, sessionid, reply)
  self.id = 12617474
  self.inviter = inviter or nil
  self.sessionid = sessionid or nil
  self.reply = reply or nil
end
function CInviteCorpsRep:marshal(os)
  os:marshalInt64(self.inviter)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.reply)
end
function CInviteCorpsRep:unmarshal(os)
  self.inviter = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CInviteCorpsRep:sizepolicy(size)
  return size <= 65535
end
return CInviteCorpsRep
