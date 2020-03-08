local PetArenaTeamInfo = require("netio.protocol.mzm.gsp.petarena.PetArenaTeamInfo")
local SGetDefendPetTeamSuccess = class("SGetDefendPetTeamSuccess")
SGetDefendPetTeamSuccess.TYPEID = 12628242
function SGetDefendPetTeamSuccess:ctor(target_roleid, rank, team_info)
  self.id = 12628242
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.team_info = team_info or PetArenaTeamInfo.new()
end
function SGetDefendPetTeamSuccess:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  self.team_info:marshal(os)
end
function SGetDefendPetTeamSuccess:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.team_info = PetArenaTeamInfo.new()
  self.team_info:unmarshal(os)
end
function SGetDefendPetTeamSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetDefendPetTeamSuccess
