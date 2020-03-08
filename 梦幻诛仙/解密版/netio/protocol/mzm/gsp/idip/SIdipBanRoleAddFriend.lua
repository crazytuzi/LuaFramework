local SIdipBanRoleAddFriend = class("SIdipBanRoleAddFriend")
SIdipBanRoleAddFriend.TYPEID = 12601105
function SIdipBanRoleAddFriend:ctor(unbanTime, reason)
  self.id = 12601105
  self.unbanTime = unbanTime or nil
  self.reason = reason or nil
end
function SIdipBanRoleAddFriend:marshal(os)
  os:marshalInt64(self.unbanTime)
  os:marshalOctets(self.reason)
end
function SIdipBanRoleAddFriend:unmarshal(os)
  self.unbanTime = os:unmarshalInt64()
  self.reason = os:unmarshalOctets()
end
function SIdipBanRoleAddFriend:sizepolicy(size)
  return size <= 65535
end
return SIdipBanRoleAddFriend
