local CAnswerAttendPreparePregnancyInvite = class("CAnswerAttendPreparePregnancyInvite")
CAnswerAttendPreparePregnancyInvite.TYPEID = 12609343
CAnswerAttendPreparePregnancyInvite.AGREE = 1
CAnswerAttendPreparePregnancyInvite.REFUSE = 2
function CAnswerAttendPreparePregnancyInvite:ctor(answer, inviterid, sessionid)
  self.id = 12609343
  self.answer = answer or nil
  self.inviterid = inviterid or nil
  self.sessionid = sessionid or nil
end
function CAnswerAttendPreparePregnancyInvite:marshal(os)
  os:marshalInt32(self.answer)
  os:marshalInt64(self.inviterid)
  os:marshalInt64(self.sessionid)
end
function CAnswerAttendPreparePregnancyInvite:unmarshal(os)
  self.answer = os:unmarshalInt32()
  self.inviterid = os:unmarshalInt64()
  self.sessionid = os:unmarshalInt64()
end
function CAnswerAttendPreparePregnancyInvite:sizepolicy(size)
  return size <= 65535
end
return CAnswerAttendPreparePregnancyInvite
