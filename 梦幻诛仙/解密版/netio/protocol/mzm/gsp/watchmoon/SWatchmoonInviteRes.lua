local SWatchmoonInviteRes = class("SWatchmoonInviteRes")
SWatchmoonInviteRes.TYPEID = 12600841
function SWatchmoonInviteRes:ctor(name1, roleid1, invitetime)
  self.id = 12600841
  self.name1 = name1 or nil
  self.roleid1 = roleid1 or nil
  self.invitetime = invitetime or nil
end
function SWatchmoonInviteRes:marshal(os)
  os:marshalString(self.name1)
  os:marshalInt64(self.roleid1)
  os:marshalInt64(self.invitetime)
end
function SWatchmoonInviteRes:unmarshal(os)
  self.name1 = os:unmarshalString()
  self.roleid1 = os:unmarshalInt64()
  self.invitetime = os:unmarshalInt64()
end
function SWatchmoonInviteRes:sizepolicy(size)
  return size <= 65535
end
return SWatchmoonInviteRes
