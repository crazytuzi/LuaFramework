local CDeleteFriendsCircleBlacklist = class("CDeleteFriendsCircleBlacklist")
CDeleteFriendsCircleBlacklist.TYPEID = 12625427
function CDeleteFriendsCircleBlacklist:ctor(black_role_id)
  self.id = 12625427
  self.black_role_id = black_role_id or nil
end
function CDeleteFriendsCircleBlacklist:marshal(os)
  os:marshalInt64(self.black_role_id)
end
function CDeleteFriendsCircleBlacklist:unmarshal(os)
  self.black_role_id = os:unmarshalInt64()
end
function CDeleteFriendsCircleBlacklist:sizepolicy(size)
  return size <= 65535
end
return CDeleteFriendsCircleBlacklist
