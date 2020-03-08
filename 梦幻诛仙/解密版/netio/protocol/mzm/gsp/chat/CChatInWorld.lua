local CChatInWorld = class("CChatInWorld")
CChatInWorld.TYPEID = 12585221
function CChatInWorld:ctor(contentType, content)
  self.id = 12585221
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInWorld:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInWorld:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInWorld:sizepolicy(size)
  return size <= 65535
end
return CChatInWorld
