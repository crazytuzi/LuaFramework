local SSyncRecallFriendsBigGiftAwardInfo = class("SSyncRecallFriendsBigGiftAwardInfo")
SSyncRecallFriendsBigGiftAwardInfo.TYPEID = 12600354
function SSyncRecallFriendsBigGiftAwardInfo:ctor(big_gift_awarded_state)
  self.id = 12600354
  self.big_gift_awarded_state = big_gift_awarded_state or nil
end
function SSyncRecallFriendsBigGiftAwardInfo:marshal(os)
  os:marshalInt32(self.big_gift_awarded_state)
end
function SSyncRecallFriendsBigGiftAwardInfo:unmarshal(os)
  self.big_gift_awarded_state = os:unmarshalInt32()
end
function SSyncRecallFriendsBigGiftAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncRecallFriendsBigGiftAwardInfo
