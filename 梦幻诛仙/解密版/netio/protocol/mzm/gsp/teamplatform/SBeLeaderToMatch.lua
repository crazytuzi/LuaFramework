local SBeLeaderToMatch = class("SBeLeaderToMatch")
SBeLeaderToMatch.TYPEID = 12593670
function SBeLeaderToMatch:ctor()
  self.id = 12593670
end
function SBeLeaderToMatch:marshal(os)
end
function SBeLeaderToMatch:unmarshal(os)
end
function SBeLeaderToMatch:sizepolicy(size)
  return size <= 65535
end
return SBeLeaderToMatch
