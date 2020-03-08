local SAnswerAttendPreparePregnancyInviteSuccess = class("SAnswerAttendPreparePregnancyInviteSuccess")
SAnswerAttendPreparePregnancyInviteSuccess.TYPEID = 12609347
SAnswerAttendPreparePregnancyInviteSuccess.AGREE = 1
SAnswerAttendPreparePregnancyInviteSuccess.REFUSE = 2
function SAnswerAttendPreparePregnancyInviteSuccess:ctor(answer, inviterid, inviteeid)
  self.id = 12609347
  self.answer = answer or nil
  self.inviterid = inviterid or nil
  self.inviteeid = inviteeid or nil
end
function SAnswerAttendPreparePregnancyInviteSuccess:marshal(os)
  os:marshalInt32(self.answer)
  os:marshalInt64(self.inviterid)
  os:marshalInt64(self.inviteeid)
end
function SAnswerAttendPreparePregnancyInviteSuccess:unmarshal(os)
  self.answer = os:unmarshalInt32()
  self.inviterid = os:unmarshalInt64()
  self.inviteeid = os:unmarshalInt64()
end
function SAnswerAttendPreparePregnancyInviteSuccess:sizepolicy(size)
  return size <= 65535
end
return SAnswerAttendPreparePregnancyInviteSuccess
