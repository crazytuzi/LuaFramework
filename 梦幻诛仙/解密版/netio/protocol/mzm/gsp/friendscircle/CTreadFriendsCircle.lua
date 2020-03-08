local CTreadFriendsCircle = class("CTreadFriendsCircle")
CTreadFriendsCircle.TYPEID = 12625411
function CTreadFriendsCircle:ctor(be_trod_role_id, be_trod_role_zone_id)
  self.id = 12625411
  self.be_trod_role_id = be_trod_role_id or nil
  self.be_trod_role_zone_id = be_trod_role_zone_id or nil
end
function CTreadFriendsCircle:marshal(os)
  os:marshalInt64(self.be_trod_role_id)
  os:marshalInt32(self.be_trod_role_zone_id)
end
function CTreadFriendsCircle:unmarshal(os)
  self.be_trod_role_id = os:unmarshalInt64()
  self.be_trod_role_zone_id = os:unmarshalInt32()
end
function CTreadFriendsCircle:sizepolicy(size)
  return size <= 65535
end
return CTreadFriendsCircle
