local SSetFriendRemarkNameSuccess = class("SSetFriendRemarkNameSuccess")
SSetFriendRemarkNameSuccess.TYPEID = 12587042
function SSetFriendRemarkNameSuccess:ctor(friendId, remarkName)
  self.id = 12587042
  self.friendId = friendId or nil
  self.remarkName = remarkName or nil
end
function SSetFriendRemarkNameSuccess:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalOctets(self.remarkName)
end
function SSetFriendRemarkNameSuccess:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.remarkName = os:unmarshalOctets()
end
function SSetFriendRemarkNameSuccess:sizepolicy(size)
  return size <= 65535
end
return SSetFriendRemarkNameSuccess
