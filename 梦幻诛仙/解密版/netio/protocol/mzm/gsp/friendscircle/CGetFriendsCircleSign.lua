local CGetFriendsCircleSign = class("CGetFriendsCircleSign")
CGetFriendsCircleSign.TYPEID = 12625426
function CGetFriendsCircleSign:ctor()
  self.id = 12625426
end
function CGetFriendsCircleSign:marshal(os)
end
function CGetFriendsCircleSign:unmarshal(os)
end
function CGetFriendsCircleSign:sizepolicy(size)
  return size <= 65535
end
return CGetFriendsCircleSign
