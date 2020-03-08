local STeamForceLandRes = class("STeamForceLandRes")
STeamForceLandRes.TYPEID = 12590936
function STeamForceLandRes:ctor(teamid)
  self.id = 12590936
  self.teamid = teamid or nil
end
function STeamForceLandRes:marshal(os)
  os:marshalInt64(self.teamid)
end
function STeamForceLandRes:unmarshal(os)
  self.teamid = os:unmarshalInt64()
end
function STeamForceLandRes:sizepolicy(size)
  return size <= 65535
end
return STeamForceLandRes
