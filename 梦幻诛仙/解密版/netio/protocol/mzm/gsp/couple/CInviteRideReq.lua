local CInviteRideReq = class("CInviteRideReq")
CInviteRideReq.TYPEID = 12600582
function CInviteRideReq:ctor(otherRoleid)
  self.id = 12600582
  self.otherRoleid = otherRoleid or nil
end
function CInviteRideReq:marshal(os)
  os:marshalInt64(self.otherRoleid)
end
function CInviteRideReq:unmarshal(os)
  self.otherRoleid = os:unmarshalInt64()
end
function CInviteRideReq:sizepolicy(size)
  return size <= 65535
end
return CInviteRideReq
