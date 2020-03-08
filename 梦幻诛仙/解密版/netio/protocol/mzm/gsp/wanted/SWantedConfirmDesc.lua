local SWantedConfirmDesc = class("SWantedConfirmDesc")
SWantedConfirmDesc.TYPEID = 12620297
function SWantedConfirmDesc:ctor(name)
  self.id = 12620297
  self.name = name or nil
end
function SWantedConfirmDesc:marshal(os)
  os:marshalOctets(self.name)
end
function SWantedConfirmDesc:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SWantedConfirmDesc:sizepolicy(size)
  return size <= 65535
end
return SWantedConfirmDesc
