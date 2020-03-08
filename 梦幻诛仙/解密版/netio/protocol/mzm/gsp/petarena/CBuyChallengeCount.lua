local CBuyChallengeCount = class("CBuyChallengeCount")
CBuyChallengeCount.TYPEID = 12628228
function CBuyChallengeCount:ctor()
  self.id = 12628228
end
function CBuyChallengeCount:marshal(os)
end
function CBuyChallengeCount:unmarshal(os)
end
function CBuyChallengeCount:sizepolicy(size)
  return size <= 65535
end
return CBuyChallengeCount
