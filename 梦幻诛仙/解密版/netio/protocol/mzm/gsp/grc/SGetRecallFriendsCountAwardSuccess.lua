local SGetRecallFriendsCountAwardSuccess = class("SGetRecallFriendsCountAwardSuccess")
SGetRecallFriendsCountAwardSuccess.TYPEID = 12600352
function SGetRecallFriendsCountAwardSuccess:ctor(award_serial_no)
  self.id = 12600352
  self.award_serial_no = award_serial_no or nil
end
function SGetRecallFriendsCountAwardSuccess:marshal(os)
  os:marshalInt32(self.award_serial_no)
end
function SGetRecallFriendsCountAwardSuccess:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
end
function SGetRecallFriendsCountAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRecallFriendsCountAwardSuccess
