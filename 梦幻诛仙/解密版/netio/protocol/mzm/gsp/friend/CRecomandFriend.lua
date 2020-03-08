local CRecomandFriend = class("CRecomandFriend")
CRecomandFriend.TYPEID = 12587035
function CRecomandFriend:ctor()
  self.id = 12587035
end
function CRecomandFriend:marshal(os)
end
function CRecomandFriend:unmarshal(os)
end
function CRecomandFriend:sizepolicy(size)
  return size <= 65535
end
return CRecomandFriend
