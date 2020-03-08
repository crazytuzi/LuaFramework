local CBuyChallengeCount = class("CBuyChallengeCount")
CBuyChallengeCount.TYPEID = 12595723
function CBuyChallengeCount:ctor(buycount)
  self.id = 12595723
  self.buycount = buycount or nil
end
function CBuyChallengeCount:marshal(os)
  os:marshalInt32(self.buycount)
end
function CBuyChallengeCount:unmarshal(os)
  self.buycount = os:unmarshalInt32()
end
function CBuyChallengeCount:sizepolicy(size)
  return size <= 65535
end
return CBuyChallengeCount
