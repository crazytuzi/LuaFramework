local SSyncGrcFriendsCountAwardInfo = class("SSyncGrcFriendsCountAwardInfo")
SSyncGrcFriendsCountAwardInfo.TYPEID = 12600339
function SSyncGrcFriendsCountAwardInfo:ctor(award_serial_no, friends_count)
  self.id = 12600339
  self.award_serial_no = award_serial_no or nil
  self.friends_count = friends_count or nil
end
function SSyncGrcFriendsCountAwardInfo:marshal(os)
  os:marshalInt32(self.award_serial_no)
  os:marshalInt32(self.friends_count)
end
function SSyncGrcFriendsCountAwardInfo:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
  self.friends_count = os:unmarshalInt32()
end
function SSyncGrcFriendsCountAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncGrcFriendsCountAwardInfo
