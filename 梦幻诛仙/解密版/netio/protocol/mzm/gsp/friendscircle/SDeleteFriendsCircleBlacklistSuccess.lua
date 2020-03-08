local SDeleteFriendsCircleBlacklistSuccess = class("SDeleteFriendsCircleBlacklistSuccess")
SDeleteFriendsCircleBlacklistSuccess.TYPEID = 12625430
function SDeleteFriendsCircleBlacklistSuccess:ctor(black_role_id)
  self.id = 12625430
  self.black_role_id = black_role_id or nil
end
function SDeleteFriendsCircleBlacklistSuccess:marshal(os)
  os:marshalInt64(self.black_role_id)
end
function SDeleteFriendsCircleBlacklistSuccess:unmarshal(os)
  self.black_role_id = os:unmarshalInt64()
end
function SDeleteFriendsCircleBlacklistSuccess:sizepolicy(size)
  return size <= 65535
end
return SDeleteFriendsCircleBlacklistSuccess
