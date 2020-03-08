local SGetFriendsCircleSignRes = class("SGetFriendsCircleSignRes")
SGetFriendsCircleSignRes.TYPEID = 12625425
function SGetFriendsCircleSignRes:ctor(timestamp, sign)
  self.id = 12625425
  self.timestamp = timestamp or nil
  self.sign = sign or nil
end
function SGetFriendsCircleSignRes:marshal(os)
  os:marshalInt64(self.timestamp)
  os:marshalOctets(self.sign)
end
function SGetFriendsCircleSignRes:unmarshal(os)
  self.timestamp = os:unmarshalInt64()
  self.sign = os:unmarshalOctets()
end
function SGetFriendsCircleSignRes:sizepolicy(size)
  return size <= 65535
end
return SGetFriendsCircleSignRes
