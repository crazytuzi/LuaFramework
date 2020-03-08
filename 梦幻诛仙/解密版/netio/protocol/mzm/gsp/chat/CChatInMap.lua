local CChatInMap = class("CChatInMap")
CChatInMap.TYPEID = 12585230
function CChatInMap:ctor(contentType, content)
  self.id = 12585230
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInMap:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInMap:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInMap:sizepolicy(size)
  return size <= 65535
end
return CChatInMap
