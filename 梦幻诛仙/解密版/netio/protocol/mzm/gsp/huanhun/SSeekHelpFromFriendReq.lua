local SSeekHelpFromFriendReq = class("SSeekHelpFromFriendReq")
SSeekHelpFromFriendReq.TYPEID = 12584461
function SSeekHelpFromFriendReq:ctor(itemIndex)
  self.id = 12584461
  self.itemIndex = itemIndex or nil
end
function SSeekHelpFromFriendReq:marshal(os)
  os:marshalInt32(self.itemIndex)
end
function SSeekHelpFromFriendReq:unmarshal(os)
  self.itemIndex = os:unmarshalInt32()
end
function SSeekHelpFromFriendReq:sizepolicy(size)
  return size <= 65535
end
return SSeekHelpFromFriendReq
