local CFriendsCircleTryTread = class("CFriendsCircleTryTread")
CFriendsCircleTryTread.TYPEID = 12625431
function CFriendsCircleTryTread:ctor(be_trod_role_id)
  self.id = 12625431
  self.be_trod_role_id = be_trod_role_id or nil
end
function CFriendsCircleTryTread:marshal(os)
  os:marshalInt64(self.be_trod_role_id)
end
function CFriendsCircleTryTread:unmarshal(os)
  self.be_trod_role_id = os:unmarshalInt64()
end
function CFriendsCircleTryTread:sizepolicy(size)
  return size <= 65535
end
return CFriendsCircleTryTread
