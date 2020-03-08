local SStartFightFailed = class("SStartFightFailed")
SStartFightFailed.TYPEID = 12628238
SStartFightFailed.ERROR_LEVEL = -1
SStartFightFailed.ERROR_ACTIVITY_JOIN = -2
SStartFightFailed.ERROR_CHALLENGE_NOT_ENOUGH = -3
SStartFightFailed.ERROR_ATTACK_TEAM_EMPTY = -4
SStartFightFailed.ERROR_DEFEND_TEAM_EMPTY = -5
SStartFightFailed.ERROR_IN_TEAM = -6
SStartFightFailed.ERROR_RANK_CHANGED = -7
SStartFightFailed.ERROR_OPPONENT_CHANGED = -8
function SStartFightFailed:ctor(target_roleid, rank, teamid, retcode)
  self.id = 12628238
  self.target_roleid = target_roleid or nil
  self.rank = rank or nil
  self.teamid = teamid or nil
  self.retcode = retcode or nil
end
function SStartFightFailed:marshal(os)
  os:marshalInt64(self.target_roleid)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.teamid)
  os:marshalInt32(self.retcode)
end
function SStartFightFailed:unmarshal(os)
  self.target_roleid = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.teamid = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SStartFightFailed:sizepolicy(size)
  return size <= 65535
end
return SStartFightFailed
