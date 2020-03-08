local CChatInAllMapReq = class("CChatInAllMapReq")
CChatInAllMapReq.TYPEID = 12585266
function CChatInAllMapReq:ctor(map_cfg_id, contentType, content)
  self.id = 12585266
  self.map_cfg_id = map_cfg_id or nil
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInAllMapReq:marshal(os)
  os:marshalInt32(self.map_cfg_id)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInAllMapReq:unmarshal(os)
  self.map_cfg_id = os:unmarshalInt32()
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInAllMapReq:sizepolicy(size)
  return size <= 65535
end
return CChatInAllMapReq
