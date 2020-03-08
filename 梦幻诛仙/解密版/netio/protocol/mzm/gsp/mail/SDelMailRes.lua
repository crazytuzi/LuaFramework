local SDelMailRes = class("SDelMailRes")
SDelMailRes.TYPEID = 12592902
function SDelMailRes:ctor(mailIndex)
  self.id = 12592902
  self.mailIndex = mailIndex or nil
end
function SDelMailRes:marshal(os)
  os:marshalInt32(self.mailIndex)
end
function SDelMailRes:unmarshal(os)
  self.mailIndex = os:unmarshalInt32()
end
function SDelMailRes:sizepolicy(size)
  return size <= 65535
end
return SDelMailRes
