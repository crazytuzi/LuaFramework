local SIsContinueScoChallenge = class("SIsContinueScoChallenge")
SIsContinueScoChallenge.TYPEID = 12587533
function SIsContinueScoChallenge:ctor()
  self.id = 12587533
end
function SIsContinueScoChallenge:marshal(os)
end
function SIsContinueScoChallenge:unmarshal(os)
end
function SIsContinueScoChallenge:sizepolicy(size)
  return size <= 65535
end
return SIsContinueScoChallenge
