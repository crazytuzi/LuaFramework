local CJoinGangReq = class("CJoinGangReq")
CJoinGangReq.TYPEID = 12589872
CJoinGangReq.NO_INVITER = -1
function CJoinGangReq:ctor(inviterId, gangId)
  self.id = 12589872
  self.inviterId = inviterId or nil
  self.gangId = gangId or nil
end
function CJoinGangReq:marshal(os)
  os:marshalInt64(self.inviterId)
  os:marshalInt64(self.gangId)
end
function CJoinGangReq:unmarshal(os)
  self.inviterId = os:unmarshalInt64()
  self.gangId = os:unmarshalInt64()
end
function CJoinGangReq:sizepolicy(size)
  return size <= 65535
end
return CJoinGangReq
