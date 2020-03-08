local CChatInBattle = class("CChatInBattle")
CChatInBattle.TYPEID = 12585225
function CChatInBattle:ctor(contentType, content)
  self.id = 12585225
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInBattle:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInBattle:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInBattle:sizepolicy(size)
  return size <= 65535
end
return CChatInBattle
