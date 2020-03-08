local CSeekHelpFromFriendReq = class("CSeekHelpFromFriendReq")
CSeekHelpFromFriendReq.TYPEID = 12584452
function CSeekHelpFromFriendReq:ctor(itemIndex)
  self.id = 12584452
  self.itemIndex = itemIndex or nil
end
function CSeekHelpFromFriendReq:marshal(os)
  os:marshalInt32(self.itemIndex)
end
function CSeekHelpFromFriendReq:unmarshal(os)
  self.itemIndex = os:unmarshalInt32()
end
function CSeekHelpFromFriendReq:sizepolicy(size)
  return size <= 65535
end
return CSeekHelpFromFriendReq
