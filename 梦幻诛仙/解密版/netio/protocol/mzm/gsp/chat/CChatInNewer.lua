local CChatInNewer = class("CChatInNewer")
CChatInNewer.TYPEID = 12585232
function CChatInNewer:ctor(contentType, content)
  self.id = 12585232
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInNewer:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInNewer:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInNewer:sizepolicy(size)
  return size <= 65535
end
return CChatInNewer
