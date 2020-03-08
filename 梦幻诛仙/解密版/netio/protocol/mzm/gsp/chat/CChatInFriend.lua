local CChatInFriend = class("CChatInFriend")
CChatInFriend.TYPEID = 12585279
function CChatInFriend:ctor(contentType, content)
  self.id = 12585279
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInFriend:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInFriend:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInFriend:sizepolicy(size)
  return size <= 65535
end
return CChatInFriend
