local CRejectJoinGangReq = class("CRejectJoinGangReq")
CRejectJoinGangReq.TYPEID = 12589848
function CRejectJoinGangReq:ctor(inviterId)
  self.id = 12589848
  self.inviterId = inviterId or nil
end
function CRejectJoinGangReq:marshal(os)
  os:marshalInt64(self.inviterId)
end
function CRejectJoinGangReq:unmarshal(os)
  self.inviterId = os:unmarshalInt64()
end
function CRejectJoinGangReq:sizepolicy(size)
  return size <= 65535
end
return CRejectJoinGangReq
