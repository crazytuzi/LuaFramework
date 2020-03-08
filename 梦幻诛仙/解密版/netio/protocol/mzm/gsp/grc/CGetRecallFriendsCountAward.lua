local CGetRecallFriendsCountAward = class("CGetRecallFriendsCountAward")
CGetRecallFriendsCountAward.TYPEID = 12600355
function CGetRecallFriendsCountAward:ctor(award_serial_no)
  self.id = 12600355
  self.award_serial_no = award_serial_no or nil
end
function CGetRecallFriendsCountAward:marshal(os)
  os:marshalInt32(self.award_serial_no)
end
function CGetRecallFriendsCountAward:unmarshal(os)
  self.award_serial_no = os:unmarshalInt32()
end
function CGetRecallFriendsCountAward:sizepolicy(size)
  return size <= 65535
end
return CGetRecallFriendsCountAward
