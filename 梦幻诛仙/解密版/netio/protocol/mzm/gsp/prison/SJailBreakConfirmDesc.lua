local SJailBreakConfirmDesc = class("SJailBreakConfirmDesc")
SJailBreakConfirmDesc.TYPEID = 12620041
function SJailBreakConfirmDesc:ctor(name)
  self.id = 12620041
  self.name = name or nil
end
function SJailBreakConfirmDesc:marshal(os)
  os:marshalOctets(self.name)
end
function SJailBreakConfirmDesc:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SJailBreakConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SJailBreakConfirmDesc
