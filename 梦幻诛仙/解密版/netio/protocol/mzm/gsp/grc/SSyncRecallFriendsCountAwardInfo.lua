local SSyncRecallFriendsCountAwardInfo = class("SSyncRecallFriendsCountAwardInfo")
SSyncRecallFriendsCountAwardInfo.TYPEID = 12600362
function SSyncRecallFriendsCountAwardInfo:ctor(award_serial_no, recall_friends_count, today_recall_friends_count)
  self.id = 12600362
  self.award_serial_no = award_serial_no or nil
  self.recall_friends_count = recall_friends_count or nil
  self.today_recall_friends_count = today_recall_friends_count or nil
end
function SSyncRecallFriendsCountAwardInfo:marshal(os)
  os:marshalInt32(self.award_serial_no)
  os:marshalInt32(self.recall_friends_count)
  os:marshalInt32(self.today_recall_friends_count)
end
function SSyncRecallFriendsCountAwardInfo:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
  self.recall_friends_count = os:unmarshalInt32()
  self.today_recall_friends_count = os:unmarshalInt32()
end
function SSyncRecallFriendsCountAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRecallFriendsCountAwardInfo
