local CBindFriendReq = class("CBindFriendReq")
CBindFriendReq.TYPEID = 12600372
function CBindFriendReq:ctor(open_id)
  self.id = 12600372
  self.open_id = open_id or nil
end
function CBindFriendReq:marshal(os)
  os:marshalOctets(self.open_id)
end
function CBindFriendReq:unmarshal(os)
  self.open_id = os:unmarshalOctets()
end
function CBindFriendReq:sizepolicy(size)
  return size <= 65535
end
return CBindFriendReq
