local CLeaveGangTeamReq = class("CLeaveGangTeamReq")
CLeaveGangTeamReq.TYPEID = 12589988
function CLeaveGangTeamReq:ctor()
  self.id = 12589988
end
function CLeaveGangTeamReq:marshal(os)
end
function CLeaveGangTeamReq:unmarshal(os)
end
function CLeaveGangTeamReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveGangTeamReq
