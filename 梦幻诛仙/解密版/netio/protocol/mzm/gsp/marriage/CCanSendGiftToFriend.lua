local CCanSendGiftToFriend = class("CCanSendGiftToFriend")
CCanSendGiftToFriend.TYPEID = 12599836
function CCanSendGiftToFriend:ctor(roleid)
  self.id = 12599836
  self.roleid = roleid or nil
end
function CCanSendGiftToFriend:marshal(os)
  os:marshalInt64(self.roleid)
end
function CCanSendGiftToFriend:unmarshal(os)
  self.roleid = os:unmarshalInt64()
end
function CCanSendGiftToFriend:sizepolicy(size)
  return size <= 65535
end
return CCanSendGiftToFriend
