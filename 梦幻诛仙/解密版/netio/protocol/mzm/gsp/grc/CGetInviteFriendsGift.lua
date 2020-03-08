local CGetInviteFriendsGift = class("CGetInviteFriendsGift")
CGetInviteFriendsGift.TYPEID = 12600347
function CGetInviteFriendsGift:ctor()
  self.id = 12600347
end
function CGetInviteFriendsGift:marshal(os)
end
function CGetInviteFriendsGift:unmarshal(os)
end
function CGetInviteFriendsGift:sizepolicy(size)
  return size <= 65535
end
return CGetInviteFriendsGift
