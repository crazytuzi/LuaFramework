local CJoinGangTeamReq = class("CJoinGangTeamReq")
CJoinGangTeamReq.TYPEID = 12589997
function CJoinGangTeamReq:ctor(teamid)
  self.id = 12589997
  self.teamid = teamid or nil
end
function CJoinGangTeamReq:marshal(os)
  os:marshalInt64(self.teamid)
end
function CJoinGangTeamReq:unmarshal(os)
  self.teamid = os:unmarshalInt64()
end
function CJoinGangTeamReq:sizepolicy(size)
  return size <= 65535
end
return CJoinGangTeamReq
