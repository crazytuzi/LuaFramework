local TeamApplicant = require("netio.protocol.mzm.gsp.team.TeamApplicant")
local SNewApplicantNotify = class("SNewApplicantNotify")
SNewApplicantNotify.TYPEID = 12588313
function SNewApplicantNotify:ctor(applicant)
  self.id = 12588313
  self.applicant = applicant or TeamApplicant.new()
end
function SNewApplicantNotify:marshal(os)
  self.applicant:marshal(os)
end
function SNewApplicantNotify:unmarshal(os)
  self.applicant = TeamApplicant.new()
  self.applicant:unmarshal(os)
end
function SNewApplicantNotify:sizepolicy(size)
  return size <= 65535
end
return SNewApplicantNotify
