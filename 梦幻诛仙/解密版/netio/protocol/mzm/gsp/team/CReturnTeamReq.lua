local CReturnTeamReq = class("CReturnTeamReq")
CReturnTeamReq.TYPEID = 12588328
function CReturnTeamReq:ctor()
  self.id = 12588328
end
function CReturnTeamReq:marshal(os)
end
function CReturnTeamReq:unmarshal(os)
end
function CReturnTeamReq:sizepolicy(size)
  return size <= 65535
end
return CReturnTeamReq
