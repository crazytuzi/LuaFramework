local CFabaoComposeReq = class("CFabaoComposeReq")
CFabaoComposeReq.TYPEID = 12596026
function CFabaoComposeReq:ctor(fabaoid, yaobaoNum)
  self.id = 12596026
  self.fabaoid = fabaoid or nil
  self.yaobaoNum = yaobaoNum or nil
end
function CFabaoComposeReq:marshal(os)
  os:marshalInt32(self.fabaoid)
  os:marshalInt32(self.yaobaoNum)
end
function CFabaoComposeReq:unmarshal(os)
  self.fabaoid = os:unmarshalInt32()
  self.yaobaoNum = os:unmarshalInt32()
end
function CFabaoComposeReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoComposeReq
