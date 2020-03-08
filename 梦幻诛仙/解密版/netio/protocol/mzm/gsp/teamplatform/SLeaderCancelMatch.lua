local SLeaderCancelMatch = class("SLeaderCancelMatch")
SLeaderCancelMatch.TYPEID = 12593683
function SLeaderCancelMatch:ctor()
  self.id = 12593683
end
function SLeaderCancelMatch:marshal(os)
end
function SLeaderCancelMatch:unmarshal(os)
end
function SLeaderCancelMatch:sizepolicy(size)
  return size <= 65535
end
return SLeaderCancelMatch
