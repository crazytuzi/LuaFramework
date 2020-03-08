local SSendGiftToFriendRes = class("SSendGiftToFriendRes")
SSendGiftToFriendRes.TYPEID = 12599834
function SSendGiftToFriendRes:ctor(roleid, giftid, timeSec)
  self.id = 12599834
  self.roleid = roleid or nil
  self.giftid = giftid or nil
  self.timeSec = timeSec or nil
end
function SSendGiftToFriendRes:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.giftid)
  os:marshalInt32(self.timeSec)
end
function SSendGiftToFriendRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.giftid = os:unmarshalInt32()
  self.timeSec = os:unmarshalInt32()
end
function SSendGiftToFriendRes:sizepolicy(size)
  return size <= 65535
end
return SSendGiftToFriendRes
