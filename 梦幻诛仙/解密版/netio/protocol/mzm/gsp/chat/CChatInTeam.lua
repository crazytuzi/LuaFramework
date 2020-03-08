local CChatInTeam = class("CChatInTeam")
CChatInTeam.TYPEID = 12585236
function CChatInTeam:ctor(contentType, content)
  self.id = 12585236
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInTeam:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInTeam:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInTeam:sizepolicy(size)
  return size <= 65535
end
return CChatInTeam
