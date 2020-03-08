local SAddGangTeamApplicantBrd = class("SAddGangTeamApplicantBrd")
SAddGangTeamApplicantBrd.TYPEID = 12589994
function SAddGangTeamApplicantBrd:ctor(applicantid)
  self.id = 12589994
  self.applicantid = applicantid or nil
end
function SAddGangTeamApplicantBrd:marshal(os)
  os:marshalInt64(self.applicantid)
end
function SAddGangTeamApplicantBrd:unmarshal(os)
  self.applicantid = os:unmarshalInt64()
end
function SAddGangTeamApplicantBrd:sizepolicy(size)
  return size <= 65535
end
return SAddGangTeamApplicantBrd
