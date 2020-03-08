local CInviteCorpsReq = class("CInviteCorpsReq")
CInviteCorpsReq.TYPEID = 12617483
function CInviteCorpsReq:ctor(invitee)
  self.id = 12617483
  self.invitee = invitee or nil
end
function CInviteCorpsReq:marshal(os)
  os:marshalInt64(self.invitee)
end
function CInviteCorpsReq:unmarshal(os)
  self.invitee = os:unmarshalInt64()
end
function CInviteCorpsReq:sizepolicy(size)
  return size <= 65535
end
return CInviteCorpsReq
