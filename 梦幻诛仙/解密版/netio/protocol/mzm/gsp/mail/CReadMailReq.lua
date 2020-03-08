local CReadMailReq = class("CReadMailReq")
CReadMailReq.TYPEID = 12592908
function CReadMailReq:ctor(mailIndex)
  self.id = 12592908
  self.mailIndex = mailIndex or nil
end
function CReadMailReq:marshal(os)
  os:marshalInt32(self.mailIndex)
end
function CReadMailReq:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
end
function CReadMailReq:sizepolicy(size)
  return size <= 65535
end
return CReadMailReq
