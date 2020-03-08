local SBuyChallengeCountFailed = class("SBuyChallengeCountFailed")
SBuyChallengeCountFailed.TYPEID = 12628229
SBuyChallengeCountFailed.ERROR_LEVEL = -1
SBuyChallengeCountFailed.ERROR_ACTIVITY_JOIN = -2
SBuyChallengeCountFailed.ERROR_COST_YUAN_BAO = -3
SBuyChallengeCountFailed.ERROR_BUY_LIMIT = -4
SBuyChallengeCountFailed.ERROR_IN_TEAM = -5
function SBuyChallengeCountFailed:ctor(retcode)
  self.id = 12628229
  self.retcode = retcode or nil
end
function SBuyChallengeCountFailed:marshal(os)
  os:marshalInt32(self.retcode)
end
function SBuyChallengeCountFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
end
function SBuyChallengeCountFailed:sizepolicy(size)
  return size <= 65535
end
return SBuyChallengeCountFailed
