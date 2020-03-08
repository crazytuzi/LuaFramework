local SFriendSendGift = class("SFriendSendGift")
SFriendSendGift.TYPEID = 12599833
function SFriendSendGift:ctor(roleid, giftid, timeSec)
  self.id = 12599833
  self.roleid = roleid or nil
  self.giftid = giftid or nil
  self.timeSec = timeSec or nil
end
function SFriendSendGift:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.giftid)
  os:marshalInt32(self.timeSec)
end
function SFriendSendGift:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.giftid = os:unmarshalInt32()
  self.timeSec = os:unmarshalInt32()
end
function SFriendSendGift:sizepolicy(size)
  return size <= 65535
end
return SFriendSendGift
