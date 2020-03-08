local CChatInRoomReq = class("CChatInRoomReq")
CChatInRoomReq.TYPEID = 12585248
function CChatInRoomReq:ctor(contentType, content)
  self.id = 12585248
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInRoomReq:marshal(os)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInRoomReq:unmarshal(os)
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInRoomReq:sizepolicy(size)
  return size <= 65535
end
return CChatInRoomReq
