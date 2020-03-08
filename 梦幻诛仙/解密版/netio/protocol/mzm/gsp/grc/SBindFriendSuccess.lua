local SBindFriendSuccess = class("SBindFriendSuccess")
SBindFriendSuccess.TYPEID = 12600374
function SBindFriendSuccess:ctor(open_id)
  self.id = 12600374
  self.open_id = open_id or nil
end
function SBindFriendSuccess:marshal(os)
  os:marshalOctets(self.open_id)
end
function SBindFriendSuccess:unmarshal(os)
  self.open_id = os:unmarshalOctets()
end
function SBindFriendSuccess:sizepolicy(size)
  return size <= 65535
end
return SBindFriendSuccess
