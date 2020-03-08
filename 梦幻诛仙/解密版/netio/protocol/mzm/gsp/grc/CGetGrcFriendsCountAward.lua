local CGetGrcFriendsCountAward = class("CGetGrcFriendsCountAward")
CGetGrcFriendsCountAward.TYPEID = 12600330
function CGetGrcFriendsCountAward:ctor(award_serial_no)
  self.id = 12600330
  self.award_serial_no = award_serial_no or nil
end
function CGetGrcFriendsCountAward:marshal(os)
  os:marshalInt32(self.award_serial_no)
end
function CGetGrcFriendsCountAward:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
end
function CGetGrcFriendsCountAward:sizepolicy(size)
  return size <= 65535
end
return CGetGrcFriendsCountAward
