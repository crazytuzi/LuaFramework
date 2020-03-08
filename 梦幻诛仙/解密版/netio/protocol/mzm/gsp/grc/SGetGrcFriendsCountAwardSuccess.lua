local SGetGrcFriendsCountAwardSuccess = class("SGetGrcFriendsCountAwardSuccess")
SGetGrcFriendsCountAwardSuccess.TYPEID = 12600340
function SGetGrcFriendsCountAwardSuccess:ctor(award_serial_no)
  self.id = 12600340
  self.award_serial_no = award_serial_no or nil
end
function SGetGrcFriendsCountAwardSuccess:marshal(os)
  os:marshalInt32(self.award_serial_no)
end
function SGetGrcFriendsCountAwardSuccess:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
end
function SGetGrcFriendsCountAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetGrcFriendsCountAwardSuccess
