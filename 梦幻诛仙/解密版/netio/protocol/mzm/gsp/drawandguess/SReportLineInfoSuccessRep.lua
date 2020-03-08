local SReportLineInfoSuccessRep = class("SReportLineInfoSuccessRep")
SReportLineInfoSuccessRep.TYPEID = 12617229
function SReportLineInfoSuccessRep:ctor()
  self.id = 12617229
end
function SReportLineInfoSuccessRep:marshal(os)
end
function SReportLineInfoSuccessRep:unmarshal(os)
end
function SReportLineInfoSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SReportLineInfoSuccessRep
