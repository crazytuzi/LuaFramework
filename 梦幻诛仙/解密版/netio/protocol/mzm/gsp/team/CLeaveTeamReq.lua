local CLeaveTeamReq = class("CLeaveTeamReq")
CLeaveTeamReq.TYPEID = 12588306
function CLeaveTeamReq:ctor()
  self.id = 12588306
end
function CLeaveTeamReq:marshal(os)
end
function CLeaveTeamReq:unmarshal(os)
end
function CLeaveTeamReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveTeamReq
