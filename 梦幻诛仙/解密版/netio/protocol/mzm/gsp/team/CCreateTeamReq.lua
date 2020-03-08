local CCreateTeamReq = class("CCreateTeamReq")
CCreateTeamReq.TYPEID = 12588319
function CCreateTeamReq:ctor()
  self.id = 12588319
end
function CCreateTeamReq:marshal(os)
end
function CCreateTeamReq:unmarshal(os)
end
function CCreateTeamReq:sizepolicy(size)
  return size <= 65535
end
return CCreateTeamReq
