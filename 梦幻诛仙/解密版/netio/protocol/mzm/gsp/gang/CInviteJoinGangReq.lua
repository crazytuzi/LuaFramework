local CInviteJoinGangReq = class("CInviteJoinGangReq")
CInviteJoinGangReq.TYPEID = 12589841
function CInviteJoinGangReq:ctor(targetId)
  self.id = 12589841
  self.targetId = targetId or nil
end
function CInviteJoinGangReq:marshal(os)
  os:marshalInt64(self.targetId)
end
function CInviteJoinGangReq:unmarshal(os)
  self.targetId = os:unmarshalInt64()
end
function CInviteJoinGangReq:sizepolicy(size)
  return size <= 65535
end
return CInviteJoinGangReq
