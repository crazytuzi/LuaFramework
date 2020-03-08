local CChatInSingleBattleCamp = class("CChatInSingleBattleCamp")
CChatInSingleBattleCamp.TYPEID = 12585277
function CChatInSingleBattleCamp:ctor(contentType, content)
  self.id = 12585277
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInSingleBattleCamp:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInSingleBattleCamp:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInSingleBattleCamp:sizepolicy(size)
  return size <= 65535
end
return CChatInSingleBattleCamp
