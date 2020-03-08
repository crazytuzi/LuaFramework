local CChatInGroupReq = class("CChatInGroupReq")
CChatInGroupReq.TYPEID = 12585253
function CChatInGroupReq:ctor(groupid, contentType, content)
  self.id = 12585253
  self.groupid = groupid or nil
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInGroupReq:marshal(os)
  os:marshalInt64(self.groupid)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInGroupReq:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInGroupReq:sizepolicy(size)
  return size <= 65535
end
return CChatInGroupReq
