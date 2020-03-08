local SInviteCorpsTrs = class("SInviteCorpsTrs")
SInviteCorpsTrs.TYPEID = 12617475
function SInviteCorpsTrs:ctor(inviter, name, corpsName, sessionid)
  self.id = 12617475
  self.inviter = inviter or nil
  self.name = name or nil
  self.corpsName = corpsName or nil
  self.sessionid = sessionid or nil
end
function SInviteCorpsTrs:marshal(os)
  os:marshalInt64(self.inviter)
  os:marshalOctets(self.name)
  os:marshalOctets(self.corpsName)
  os:marshalInt64(self.sessionid)
end
function SInviteCorpsTrs:unmarshal(os)
  self.inviter = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.corpsName = os:unmarshalOctets()
  self.sessionid = os:unmarshalInt64()
end
function SInviteCorpsTrs:sizepolicy(size)
  return size <= 65535
end
return SInviteCorpsTrs
