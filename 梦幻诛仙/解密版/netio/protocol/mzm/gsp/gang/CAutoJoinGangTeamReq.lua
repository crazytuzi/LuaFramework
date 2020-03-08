local CAutoJoinGangTeamReq = class("CAutoJoinGangTeamReq")
CAutoJoinGangTeamReq.TYPEID = 12590000
function CAutoJoinGangTeamReq:ctor()
  self.id = 12590000
end
function CAutoJoinGangTeamReq:marshal(os)
end
function CAutoJoinGangTeamReq:unmarshal(os)
end
function CAutoJoinGangTeamReq:sizepolicy(size)
  return size <= 65535
end
return CAutoJoinGangTeamReq
