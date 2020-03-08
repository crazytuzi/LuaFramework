local SAddFriendsCircleBlacklistSuccess = class("SAddFriendsCircleBlacklistSuccess")
SAddFriendsCircleBlacklistSuccess.TYPEID = 12625429
function SAddFriendsCircleBlacklistSuccess:ctor(black_role_id)
  self.id = 12625429
  self.black_role_id = black_role_id or nil
end
function SAddFriendsCircleBlacklistSuccess:marshal(os)
  os:marshalInt64(self.black_role_id)
end
function SAddFriendsCircleBlacklistSuccess:unmarshal(os)
  self.black_role_id = os:unmarshalInt64()
end
function SAddFriendsCircleBlacklistSuccess:sizepolicy(size)
  return size <= 65535
end
return SAddFriendsCircleBlacklistSuccess
