local CSetFriendRemarkNameReq = class("CSetFriendRemarkNameReq")
CSetFriendRemarkNameReq.TYPEID = 12587044
function CSetFriendRemarkNameReq:ctor(friendId, remarkName)
  self.id = 12587044
  self.friendId = friendId or nil
  self.remarkName = remarkName or nil
end
function CSetFriendRemarkNameReq:marshal(os)
  os:marshalInt64(self.friendId)
  os:marshalOctets(self.remarkName)
end
function CSetFriendRemarkNameReq:unmarshal(os)
  self.friendId = os:unmarshalInt64()
  self.remarkName = os:unmarshalOctets()
end
function CSetFriendRemarkNameReq:sizepolicy(size)
  return size <= 65535
end
return CSetFriendRemarkNameReq
