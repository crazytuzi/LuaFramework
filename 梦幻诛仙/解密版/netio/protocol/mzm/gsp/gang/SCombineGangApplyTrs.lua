local CombineGang = require("netio.protocol.mzm.gsp.gang.CombineGang")
local SCombineGangApplyTrs = class("SCombineGangApplyTrs")
SCombineGangApplyTrs.TYPEID = 12589965
function SCombineGangApplyTrs:ctor(applicant)
  self.id = 12589965
  self.applicant = applicant or CombineGang.new()
end
function SCombineGangApplyTrs:marshal(os)
  self.applicant:marshal(os)
end
function SCombineGangApplyTrs:unmarshal(os)
  self.applicant = CombineGang.new()
  self.applicant:unmarshal(os)
end
function SCombineGangApplyTrs:sizepolicy(size)
  return size <= 65535
end
return SCombineGangApplyTrs
