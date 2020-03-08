local CAddFriendsCircleBlacklist = class("CAddFriendsCircleBlacklist")
CAddFriendsCircleBlacklist.TYPEID = 12625428
function CAddFriendsCircleBlacklist:ctor(black_role_id, black_role_server_id)
  self.id = 12625428
  self.black_role_id = black_role_id or nil
  self.black_role_server_id = black_role_server_id or nil
end
function CAddFriendsCircleBlacklist:marshal(os)
  os:marshalInt64(self.black_role_id)
  os:marshalInt32(self.black_role_server_id)
end
function CAddFriendsCircleBlacklist:unmarshal(os)
  self.black_role_id = os:unmarshalInt64()
  self.black_role_server_id = os:unmarshalInt32()
end
function CAddFriendsCircleBlacklist:sizepolicy(size)
  return size <= 65535
end
return CAddFriendsCircleBlacklist
