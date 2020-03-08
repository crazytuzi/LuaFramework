local CChatInFaction = class("CChatInFaction")
CChatInFaction.TYPEID = 12585228
function CChatInFaction:ctor(contentType, content)
  self.id = 12585228
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInFaction:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInFaction:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInFaction:sizepolicy(size)
  return size <= 65535
end
return CChatInFaction
