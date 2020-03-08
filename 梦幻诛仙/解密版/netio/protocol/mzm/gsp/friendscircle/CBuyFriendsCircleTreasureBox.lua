local CBuyFriendsCircleTreasureBox = class("CBuyFriendsCircleTreasureBox")
CBuyFriendsCircleTreasureBox.TYPEID = 12625415
function CBuyFriendsCircleTreasureBox:ctor(buy_count, client_currency_value)
  self.id = 12625415
  self.buy_count = buy_count or nil
  self.client_currency_value = client_currency_value or nil
end
function CBuyFriendsCircleTreasureBox:marshal(os)
  os:marshalInt32(self.buy_count)
  os:marshalInt64(self.client_currency_value)
end
function CBuyFriendsCircleTreasureBox:unmarshal(os)
  self.buy_count = os:unmarshalInt32()
  self.client_currency_value = os:unmarshalInt64()
end
function CBuyFriendsCircleTreasureBox:sizepolicy(size)
  return size <= 65535
end
return CBuyFriendsCircleTreasureBox
