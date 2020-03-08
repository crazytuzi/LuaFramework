local CChatToSomeOne = class("CChatToSomeOne")
CChatToSomeOne.TYPEID = 12585220
function CChatToSomeOne:ctor(roleId, contentType, content)
  self.id = 12585220
  self.roleId = roleId or nil
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatToSomeOne:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatToSomeOne:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatToSomeOne:sizepolicy(size)
  return size <= 65535
end
return CChatToSomeOne
