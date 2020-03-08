local SBuyChallengeCountRes = class("SBuyChallengeCountRes")
SBuyChallengeCountRes.TYPEID = 12595724
function SBuyChallengeCountRes:ctor(buycount, challengeCount, totalbuycount)
  self.id = 12595724
  self.buycount = buycount or nil
  self.challengeCount = challengeCount or nil
  self.totalbuycount = totalbuycount or nil
end
function SBuyChallengeCountRes:marshal(os)
  os:marshalInt32(self.buycount)
  os:marshalInt32(self.challengeCount)
  os:marshalInt32(self.totalbuycount)
end
function SBuyChallengeCountRes:unmarshal(os)
  self.buycount = os:unmarshalInt32()
  self.challengeCount = os:unmarshalInt32()
  self.totalbuycount = os:unmarshalInt32()
end
function SBuyChallengeCountRes:sizepolicy(size)
  return size <= 65535
end
return SBuyChallengeCountRes
