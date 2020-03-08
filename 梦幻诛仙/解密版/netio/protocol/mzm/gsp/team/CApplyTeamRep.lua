local CApplyTeamRep = class("CApplyTeamRep")
CApplyTeamRep.TYPEID = 12588293
CApplyTeamRep.REPLY_ACCEPT = 1
CApplyTeamRep.REPLY_REFUSE = 2
function CApplyTeamRep:ctor(applicant, reply)
  self.id = 12588293
  self.applicant = applicant or nil
  self.reply = reply or nil
end
function CApplyTeamRep:marshal(os)
  os:marshalInt64(self.applicant)
  os:marshalInt32(self.reply)
end
function CApplyTeamRep:unmarshal(os)
  self.applicant = os:unmarshalInt64()
  self.reply = os:unmarshalInt32()
end
function CApplyTeamRep:sizepolicy(size)
  return size <= 65535
end
return CApplyTeamRep
