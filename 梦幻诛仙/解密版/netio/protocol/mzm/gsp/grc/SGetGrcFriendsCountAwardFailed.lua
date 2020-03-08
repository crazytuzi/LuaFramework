local SGetGrcFriendsCountAwardFailed = class("SGetGrcFriendsCountAwardFailed")
SGetGrcFriendsCountAwardFailed.TYPEID = 12600333
SGetGrcFriendsCountAwardFailed.ERR_SERIAL_NO_INVALID = -1
SGetGrcFriendsCountAwardFailed.ERR_FRIENDS_COUNT_NOT_MEET = -2
SGetGrcFriendsCountAwardFailed.ERR_AWARD_FAILED = -3
function SGetGrcFriendsCountAwardFailed:ctor(retcode, award_serial_no)
  self.id = 12600333
  self.retcode = retcode or nil
  self.award_serial_no = award_serial_no or nil
end
function SGetGrcFriendsCountAwardFailed:marshal(os)
  os:marshalInt32(self.retcode)
  os:marshalInt32(self.award_serial_no)
end
function SGetGrcFriendsCountAwardFailed:unmarshal(os)
  self.retcode = os:unmarshalInt32()
  self.award_serial_no = os:unmarshalInt32()
end
function SGetGrcFriendsCountAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetGrcFriendsCountAwardFailed
