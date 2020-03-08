local SCanSendGiftToFriend = class("SCanSendGiftToFriend")
SCanSendGiftToFriend.TYPEID = 12599835
SCanSendGiftToFriend.SUC = 0
SCanSendGiftToFriend.ALREADY_SEND = 1
SCanSendGiftToFriend.OUT_OF_DATE = 2
SCanSendGiftToFriend.NOT_IN_MARRIAGE = 3
function SCanSendGiftToFriend:ctor(friendid, ret)
  self.id = 12599835
  self.friendid = friendid or nil
  self.ret = ret or nil
end
function SCanSendGiftToFriend:marshal(os)
  os:marshalInt64(self.friendid)
  os:marshalInt32(self.ret)
end
function SCanSendGiftToFriend:unmarshal(os)
  self.friendid = os:unmarshalInt64()
  self.ret = os:unmarshalInt32()
end
function SCanSendGiftToFriend:sizepolicy(size)
  return size <= 65535
end
return SCanSendGiftToFriend
