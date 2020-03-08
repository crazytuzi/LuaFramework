local STransmitAttendPreparePregnancyInvite = class("STransmitAttendPreparePregnancyInvite")
STransmitAttendPreparePregnancyInvite.TYPEID = 12609342
function STransmitAttendPreparePregnancyInvite:ctor(inviterid, sessionid)
  self.id = 12609342
  self.inviterid = inviterid or nil
  self.sessionid = sessionid or nil
end
function STransmitAttendPreparePregnancyInvite:marshal(os)
  os:marshalInt64(self.inviterid)
  os:marshalInt64(self.sessionid)
end
function STransmitAttendPreparePregnancyInvite:unmarshal(os)
  self.inviterid = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
end
function STransmitAttendPreparePregnancyInvite:sizepolicy(size)
  return size <= 65535
end
return STransmitAttendPreparePregnancyInvite
