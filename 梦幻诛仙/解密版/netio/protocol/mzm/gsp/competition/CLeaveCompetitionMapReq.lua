local CLeaveCompetitionMapReq = class("CLeaveCompetitionMapReq")
CLeaveCompetitionMapReq.TYPEID = 12598542
function CLeaveCompetitionMapReq:ctor()
  self.id = 12598542
end
function CLeaveCompetitionMapReq:marshal(os)
end
function CLeaveCompetitionMapReq:unmarshal(os)
end
function CLeaveCompetitionMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveCompetitionMapReq
