local SStartVoteFightFailed = class("SStartVoteFightFailed")
SStartVoteFightFailed.TYPEID = 12612372
SStartVoteFightFailed.ERROR_LEVEL = -1
SStartVoteFightFailed.ERROR_LEVEL_LESS_SERVER = -2
SStartVoteFightFailed.ERROR_FIGHT_NUM_LIMIT = -3
SStartVoteFightFailed.ERROR_SUCCESSED = -4
SStartVoteFightFailed.ERROR_IN_TEAM = -5
SStartVoteFightFailed.ERROR_CANNOT_JOIN_ACTIVITY = -6
SStartVoteFightFailed.ERROR_ACTIVITY_IN_AWARD = -7
function SStartVoteFightFailed:ctor(retcode)
  self.id = 12612372
  self.retcode = retcode or nil
end
function SStartVoteFightFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SStartVoteFightFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SStartVoteFightFailed:sizepolicy(size)
  return size <= 65535
end
return SStartVoteFightFailed
