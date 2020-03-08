local CSendGiftToFriend = class("CSendGiftToFriend")
CSendGiftToFriend.TYPEID = 12599809
function CSendGiftToFriend:ctor(roleid, giftid)
  self.id = 12599809
  self.roleid = roleid or nil
  self.giftid = giftid or nil
end
function CSendGiftToFriend:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.giftid)
end
function CSendGiftToFriend:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.giftid = os:unmarshalInt32()
end
function CSendGiftToFriend:sizepolicy(size)
  return size <= 65535
end
return CSendGiftToFriend
