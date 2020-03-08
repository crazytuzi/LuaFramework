local CJoinTeamByPlatformReq = class("CJoinTeamByPlatformReq")
CJoinTeamByPlatformReq.TYPEID = 12588302
function CJoinTeamByPlatformReq:ctor(teamId)
  self.id = 12588302
  self.teamId = teamId or nil
end
function CJoinTeamByPlatformReq:marshal(os)
  os:marshalInt64(self.teamId)
end
function CJoinTeamByPlatformReq:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function CJoinTeamByPlatformReq:sizepolicy(size)
  return size <= 65535
end
return CJoinTeamByPlatformReq
