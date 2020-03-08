local SGiveFriendsCircleGiftSuccess = class("SGiveFriendsCircleGiftSuccess")
SGiveFriendsCircleGiftSuccess.TYPEID = 12625413
function SGiveFriendsCircleGiftSuccess:ctor(item_cfg_id, gift_grade, popularity_week_value, popularity_total_value, now_receive_gift_num, receive_gift_role_id, receive_gift_role_name, message)
  self.id = 12625413
  self.item_cfg_id = item_cfg_id or nil
  self.gift_grade = gift_grade or nil
  self.popularity_week_value = popularity_week_value or nil
  self.popularity_total_value = popularity_total_value or nil
  self.now_receive_gift_num = now_receive_gift_num or nil
  self.receive_gift_role_id = receive_gift_role_id or nil
  self.receive_gift_role_name = receive_gift_role_name or nil
  self.message = message or nil
end
function SGiveFriendsCircleGiftSuccess:marshal(os)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.gift_grade)
  os:marshalInt32(self.popularity_week_value)
  os:marshalInt32(self.popularity_total_value)
  os:marshalInt32(self.now_receive_gift_num)
  os:marshalInt64(self.receive_gift_role_id)
  os:marshalOctets(self.receive_gift_role_name)
  os:marshalOctets(self.message)
end
function SGiveFriendsCircleGiftSuccess:unmarshal(os)
  self.item_cfg_id = os:unmarshalInt32()
  self.gift_grade = os:unmarshalInt32()
  self.popularity_week_value = os:unmarshalInt32()
  self.popularity_total_value = os:unmarshalInt32()
  self.now_receive_gift_num = os:unmarshalInt32()
  self.receive_gift_role_id = os:unmarshalInt64()
  self.receive_gift_role_name = os:unmarshalOctets()
  self.message = os:unmarshalOctets()
end
function SGiveFriendsCircleGiftSuccess:sizepolicy(size)
  return size <= 65535
end
return SGiveFriendsCircleGiftSuccess
