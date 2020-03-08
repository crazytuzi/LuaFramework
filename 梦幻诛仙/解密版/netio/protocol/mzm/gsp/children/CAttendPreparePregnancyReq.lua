local CAttendPreparePregnancyReq = class("CAttendPreparePregnancyReq")
CAttendPreparePregnancyReq.TYPEID = 12609341
function CAttendPreparePregnancyReq:ctor(inviteeid)
  self.id = 12609341
  self.inviteeid = inviteeid or nil
end
function CAttendPreparePregnancyReq:marshal(os)
  os:marshalInt64(self.inviteeid)
end
function CAttendPreparePregnancyReq:unmarshal(os)
  self.inviteeid = os:unmarshalInt64()
end
function CAttendPreparePregnancyReq:sizepolicy(size)
  return size <= 65535
end
return CAttendPreparePregnancyReq
