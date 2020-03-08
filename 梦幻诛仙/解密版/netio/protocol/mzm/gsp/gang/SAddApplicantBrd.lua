local Applicant = require("netio.protocol.mzm.gsp.gang.Applicant")
local SAddApplicantBrd = class("SAddApplicantBrd")
SAddApplicantBrd.TYPEID = 12589952
function SAddApplicantBrd:ctor(applicant)
  self.id = 12589952
  self.applicant = applicant or Applicant.new()
end
function SAddApplicantBrd:marshal(os)
  self.applicant:marshal(os)
end
function SAddApplicantBrd:unmarshal(os)
  self.applicant = Applicant.new()
  self.applicant:unmarshal(os)
end
function SAddApplicantBrd:sizepolicy(size)
  return size <= 65535
end
return SAddApplicantBrd
