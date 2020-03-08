local STreadFriendsCircleSuccess = class("STreadFriendsCircleSuccess")
STreadFriendsCircleSuccess.TYPEID = 12625410
function STreadFriendsCircleSuccess:ctor(is_trigger_box, be_trod_role_id, popularity_week_value, popularity_total_value, add_popularity_total_value, is_auto_tread)
  self.id = 12625410
  self.is_trigger_box = is_trigger_box or nil
  self.be_trod_role_id = be_trod_role_id or nil
  self.popularity_week_value = popularity_week_value or nil
  self.popularity_total_value = popularity_total_value or nil
  self.add_popularity_total_value = add_popularity_total_value or nil
  self.is_auto_tread = is_auto_tread or nil
end
function STreadFriendsCircleSuccess:marshal(os)
  os:marshalUInt8(self.is_trigger_box)
  os:marshalInt64(self.be_trod_role_id)
  os:marshalInt32(self.popularity_week_value)
  os:marshalInt32(self.popularity_total_value)
  os:marshalInt32(self.add_popularity_total_value)
  os:marshalUInt8(self.is_auto_tread)
end
function STreadFriendsCircleSuccess:unmarshal(os)
  self.is_trigger_box = os:unmarshalUInt8()
  self.be_trod_role_id = os:unmarshalInt64()
  self.popularity_week_value = os:unmarshalInt32()
  self.popularity_total_value = os:unmarshalInt32()
  self.add_popularity_total_value = os:unmarshalInt32()
  self.is_auto_tread = os:unmarshalUInt8()
end
function STreadFriendsCircleSuccess:sizepolicy(size)
  return size <= 65535
end
return STreadFriendsCircleSuccess
