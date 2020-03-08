local CDelMailReq = class("CDelMailReq")
CDelMailReq.TYPEID = 12592903
function CDelMailReq:ctor(mailIndex)
  self.id = 12592903
  self.mailIndex = mailIndex or nil
end
function CDelMailReq:marshal(os)
  os:marshalInt32(self.mailIndex)
end
function CDelMailReq:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
end
function CDelMailReq:sizepolicy(size)
  return size <= 65535
end
return CDelMailReq
