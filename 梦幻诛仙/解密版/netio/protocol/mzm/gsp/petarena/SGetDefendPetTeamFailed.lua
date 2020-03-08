local SGetDefendPetTeamFailed = class("SGetDefendPetTeamFailed")
SGetDefendPetTeamFailed.TYPEID = 12628244
SGetDefendPetTeamFailed.ERROR_LEVEL = -1
SGetDefendPetTeamFailed.ERROR_RANK_CHANGED = -2
SGetDefendPetTeamFailed.ERROR_OPPONENT_CHANGED = -3
function SGetDefendPetTeamFailed:ctor(target_roleid, rank, retcode)
  self.id = 12628244
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.retcode = retcode or nil
end
function SGetDefendPetTeamFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.retcode)
end
function SGetDefendPetTeamFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetDefendPetTeamFailed:sizepolicy(size)
  return size <= 65535
end
return SGetDefendPetTeamFailed
