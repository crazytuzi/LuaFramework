local CChatInAnchor = class("CChatInAnchor")
CChatInAnchor.TYPEID = 12585241
function CChatInAnchor:ctor(roomType, contentType, content)
  self.id = 12585241
  self.roomType = roomType or nil
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInAnchor:marshal(os)
  os:marshalInt32(self.roomType)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInAnchor:unmarshal(os)
  self.roomType = os:unmarshalInt32()
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInAnchor:sizepolicy(size)
  return size <= 65535
end
return CChatInAnchor
