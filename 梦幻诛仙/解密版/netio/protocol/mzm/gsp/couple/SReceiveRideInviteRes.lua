local SReceiveRideInviteRes = class("SReceiveRideInviteRes")
SReceiveRideInviteRes.TYPEID = 12600578
function SReceiveRideInviteRes:ctor(sessionid, inviteRoleid, inviteRoleName)
  self.id = 12600578
  self.sessionid = sessionid or nil
  self.inviteRoleid = inviteRoleid or nil
  self.inviteRoleName = inviteRoleName or nil
end
function SReceiveRideInviteRes:marshal(os)
  os:marshalInt64(self.sessionid)
  os:marshalInt64(self.inviteRoleid)
  os:marshalString(self.inviteRoleName)
end
function SReceiveRideInviteRes:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
  self.inviteRoleid = os:unmarshalInt64()
  self.inviteRoleName = os:unmarshalString()
end
function SReceiveRideInviteRes:sizepolicy(size)
  return size <= 65535
end
return SReceiveRideInviteRes
