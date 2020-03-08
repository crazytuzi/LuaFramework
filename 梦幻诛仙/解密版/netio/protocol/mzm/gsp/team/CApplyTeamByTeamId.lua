local CApplyTeamByTeamId = class("CApplyTeamByTeamId")
CApplyTeamByTeamId.TYPEID = 12588321
function CApplyTeamByTeamId:ctor(teamId)
  self.id = 12588321
  self.teamId = teamId or nil
end
function CApplyTeamByTeamId:marshal(os)
  os:marshalInt64(self.teamId)
end
function CApplyTeamByTeamId:unmarshal(os)
  self.teamId = os:unmarshalInt64()
end
function CApplyTeamByTeamId:sizepolicy(size)
  return size <= 65535
end
return CApplyTeamByTeamId
