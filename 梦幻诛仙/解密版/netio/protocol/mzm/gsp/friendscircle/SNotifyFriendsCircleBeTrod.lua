local SNotifyFriendsCircleBeTrod = class("SNotifyFriendsCircleBeTrod")
SNotifyFriendsCircleBeTrod.TYPEID = 12625422
function SNotifyFriendsCircleBeTrod:ctor(popularity_week_value, popularity_total_value, current_treasure_box_num, is_trigger_box)
  self.id = 12625422
  self.popularity_week_value = popularity_week_value or nil
  self.popularity_total_value = popularity_total_value or nil
  self.current_treasure_box_num = current_treasure_box_num or nil
  self.is_trigger_box = is_trigger_box or nil
end
function SNotifyFriendsCircleBeTrod:marshal(os)
  os:marshalInt32(self.popularity_week_value)
  os:marshalInt32(self.popularity_total_value)
  os:marshalInt32(self.current_treasure_box_num)
  os:marshalUInt8(self.is_trigger_box)
end
function SNotifyFriendsCircleBeTrod:unmarshal(os)
  self.popularity_week_value = os:unmarshalInt32()
  self.popularity_total_value = os:unmarshalInt32()
  self.current_treasure_box_num = os:unmarshalInt32()
  self.is_trigger_box = os:unmarshalUInt8()
end
function SNotifyFriendsCircleBeTrod:sizepolicy(size)
  return size <= 65535
end
return SNotifyFriendsCircleBeTrod
