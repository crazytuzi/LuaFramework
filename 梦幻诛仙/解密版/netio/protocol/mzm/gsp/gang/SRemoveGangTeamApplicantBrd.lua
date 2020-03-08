local SRemoveGangTeamApplicantBrd = class("SRemoveGangTeamApplicantBrd")
SRemoveGangTeamApplicantBrd.TYPEID = 12590001
function SRemoveGangTeamApplicantBrd:ctor(applicantid)
  self.id = 12590001
  self.applicantid = applicantid or nil
end
function SRemoveGangTeamApplicantBrd:marshal(os)
  os:marshalInt64(self.applicantid)
end
function SRemoveGangTeamApplicantBrd:unmarshal(os)
  self.applicantid = os:unmarshalInt64()
end
function SRemoveGangTeamApplicantBrd:sizepolicy(size)
  return size <= 65535
end
return SRemoveGangTeamApplicantBrd
