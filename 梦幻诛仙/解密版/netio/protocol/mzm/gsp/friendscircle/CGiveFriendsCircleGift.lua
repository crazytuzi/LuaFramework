local CGiveFriendsCircleGift = class("CGiveFriendsCircleGift")
CGiveFriendsCircleGift.TYPEID = 12625419
function CGiveFriendsCircleGift:ctor(receive_gift_role_id, receive_gift_role_zone_id, item_cfg_id, gift_grade, client_currency_value, is_use_yuan_bao, message, client_need_yuan_bao)
  self.id = 12625419
  self.receive_gift_role_id = receive_gift_role_id or nil
  self.receive_gift_role_zone_id = receive_gift_role_zone_id or nil
  self.item_cfg_id = item_cfg_id or nil
  self.gift_grade = gift_grade or nil
  self.client_currency_value = client_currency_value or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.message = message or nil
  self.client_need_yuan_bao = client_need_yuan_bao or nil
end
function CGiveFriendsCircleGift:marshal(os)
  os:marshalInt64(self.receive_gift_role_id)
  os:marshalInt32(self.receive_gift_role_zone_id)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.gift_grade)
  os:marshalInt64(self.client_currency_value)
  os:marshalUInt8(self.is_use_yuan_bao)
  os:marshalOctets(self.message)
  os:marshalInt32(self.client_need_yuan_bao)
end
function CGiveFriendsCircleGift:unmarshal(os)
  self.receive_gift_role_id = os:unmarshalInt64()
  self.receive_gift_role_zone_id = os:unmarshalInt32()
  self.item_cfg_id = os:unmarshalInt32()
  self.gift_grade = os:unmarshalInt32()
  self.client_currency_value = os:unmarshalInt64()
  self.is_use_yuan_bao = os:unmarshalUInt8()
  self.message = os:unmarshalOctets()
  self.client_need_yuan_bao = os:unmarshalInt32()
end
function CGiveFriendsCircleGift:sizepolicy(size)
  return size <= 65535
end
return CGiveFriendsCircleGift
