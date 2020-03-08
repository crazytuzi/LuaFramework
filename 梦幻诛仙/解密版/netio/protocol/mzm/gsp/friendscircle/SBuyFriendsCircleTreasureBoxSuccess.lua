local SBuyFriendsCircleTreasureBoxSuccess = class("SBuyFriendsCircleTreasureBoxSuccess")
SBuyFriendsCircleTreasureBoxSuccess.TYPEID = 12625417
function SBuyFriendsCircleTreasureBoxSuccess:ctor(now_treasure_box_num)
  self.id = 12625417
  self.now_treasure_box_num = now_treasure_box_num or nil
end
function SBuyFriendsCircleTreasureBoxSuccess:marshal(os)
  os:marshalInt32(self.now_treasure_box_num)
end
function SBuyFriendsCircleTreasureBoxSuccess:unmarshal(os)
  self.now_treasure_box_num = os:unmarshalInt32()
end
function SBuyFriendsCircleTreasureBoxSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyFriendsCircleTreasureBoxSuccess
