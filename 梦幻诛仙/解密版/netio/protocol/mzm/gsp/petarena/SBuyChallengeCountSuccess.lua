local SBuyChallengeCountSuccess = class("SBuyChallengeCountSuccess")
SBuyChallengeCountSuccess.TYPEID = 12628236
function SBuyChallengeCountSuccess:ctor(challenge_count, buy_count)
  self.id = 12628236
  self.challenge_count = challenge_count or nil
  self.buy_count = buy_count or nil
end
function SBuyChallengeCountSuccess:marshal(os)
  os:marshalInt32(self.challenge_count)
  os:marshalInt32(self.buy_count)
end
function SBuyChallengeCountSuccess:unmarshal(os)
  self.challenge_count = os:unmarshalInt32()
  self.buy_count = os:unmarshalInt32()
end
function SBuyChallengeCountSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyChallengeCountSuccess
