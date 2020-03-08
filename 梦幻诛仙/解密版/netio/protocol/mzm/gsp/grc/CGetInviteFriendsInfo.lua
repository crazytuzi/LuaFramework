local CGetInviteFriendsInfo = class("CGetInviteFriendsInfo")
CGetInviteFriendsInfo.TYPEID = 12600348
function CGetInviteFriendsInfo:ctor()
  self.id = 12600348
end
function CGetInviteFriendsInfo:marshal(os)
end
function CGetInviteFriendsInfo:unmarshal(os)
end
function CGetInviteFriendsInfo:sizepolicy(size)
  return size <= 65535
end
return CGetInviteFriendsInfo
