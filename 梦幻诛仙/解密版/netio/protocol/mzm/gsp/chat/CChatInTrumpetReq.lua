local CChatInTrumpetReq = class("CChatInTrumpetReq")
CChatInTrumpetReq.TYPEID = 12585272
function CChatInTrumpetReq:ctor(trumpet_cfg_id, current_yuanbao_num, contentType, content)
  self.id = 12585272
  self.trumpet_cfg_id = trumpet_cfg_id or nil
  self.current_yuanbao_num = current_yuanbao_num or nil
  self.contentType = contentType or nil
  self.content = content or nil
end
function CChatInTrumpetReq:marshal(os)
  os:marshalInt32(self.trumpet_cfg_id)
  os:marshalInt32(self.current_yuanbao_num)
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
end
function CChatInTrumpetReq:unmarshal(os)
  self.trumpet_cfg_id = os:unmarshalInt32()
  self.current_yuanbao_num = os:unmarshalInt32()
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
function CChatInTrumpetReq:sizepolicy(size)
  return size <= 65535
end
return CChatInTrumpetReq
