local SIdipMessage = class("SIdipMessage")
SIdipMessage.TYPEID = 12601095
function SIdipMessage:ctor(message)
  self.id = 12601095
  self.message = message or nil
end
function SIdipMessage:marshal(os)
  os:marshalOctets(self.message)
end
function SIdipMessage:unmarshal(os)
  self.message = os:unmarshalOctets()
end
function SIdipMessage:sizepolicy(size)
  return size <= 65535
end
return SIdipMessage
