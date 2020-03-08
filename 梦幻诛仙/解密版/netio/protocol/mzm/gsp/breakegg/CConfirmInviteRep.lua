local CConfirmInviteRep = class("CConfirmInviteRep")
CConfirmInviteRep.TYPEID = 12623370
CConfirmInviteRep.REPLY_ACCEPT = 1
CConfirmInviteRep.REPLY_REFUSE = 2
function CConfirmInviteRep:ctor(invite_type, sessionid, reply)
  self.id = 12623370
  self.invite_type = invite_type or nil
  self.sessionid = sessionid or nil
  self.reply = reply or nil
end
function CConfirmInviteRep:marshal(os)
  os:marshalInt32(self.invite_type)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.reply)
end
function CConfirmInviteRep:unmarshal(os)
  self.invite_type = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CConfirmInviteRep:sizepolicy(size)
  return size <= 65535
end
return CConfirmInviteRep
