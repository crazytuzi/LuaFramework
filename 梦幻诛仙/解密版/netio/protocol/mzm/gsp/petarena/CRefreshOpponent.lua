local CRefreshOpponent = class("CRefreshOpponent")
CRefreshOpponent.TYPEID = 12628230
function CRefreshOpponent:ctor()
  self.id = 12628230
end
function CRefreshOpponent:marshal(os)
end
function CRefreshOpponent:unmarshal(os)
end
function CRefreshOpponent:sizepolicy(size)
  return size <= 65535
end
return CRefreshOpponent
