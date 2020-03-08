local SReceiveFriendsCircleGiftSuccess = class("SReceiveFriendsCircleGiftSuccess")
SReceiveFriendsCircleGiftSuccess.TYPEID = 12625414
function SReceiveFriendsCircleGiftSuccess:ctor(item_cfg_id, gift_grade, popularity_week_value, popularity_total_value, now_receive_gift_num, active_send_gift_role_name, message)
  self.id = 12625414
  self.item_cfg_id = item_cfg_id or nil
  self.gift_grade = gift_grade or nil
  self.popularity_week_value = popularity_week_value or nil
  self.popularity_total_value = popularity_total_value or nil
  self.now_receive_gift_num = now_receive_gift_num or nil
  self.active_send_gift_role_name = active_send_gift_role_name or nil
  self.message = message or nil
end
function SReceiveFriendsCircleGiftSuccess:marshal(os)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.gift_grade)
  os:marshalInt32(self.popularity_week_value)
  os:marshalInt32(self.popularity_total_value)
  os:marshalInt32(self.now_receive_gift_num)
  os:marshalOctets(self.active_send_gift_role_name)
  os:marshalOctets(self.message)
end
function SReceiveFriendsCircleGiftSuccess:unmarshal(os)
  self.item_cfg_id = os:unmarshalInt32()
  self.gift_grade = os:unmarshalInt32()
  self.popularity_week_value = os:unmarshalInt32()
  self.popularity_total_value = os:unmarshalInt32()
  self.now_receive_gift_num = os:unmarshalInt32()
  self.active_send_gift_role_name = os:unmarshalOctets()
  self.message = os:unmarshalOctets()
end
function SReceiveFriendsCircleGiftSuccess:sizepolicy(size)
  return size <= 65535
end
return SReceiveFriendsCircleGiftSuccess
