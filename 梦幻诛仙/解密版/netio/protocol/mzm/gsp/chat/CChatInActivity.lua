local CChatInActivity = class("CChatInActivity")
CChatInActivity.TYPEID = 12585219
function CChatInActivity:ctor(contentType, content)
  self.id = 12585219
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInActivity:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInActivity:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInActivity:sizepolicy(size)
  return size <= 65535
end
return CChatInActivity
