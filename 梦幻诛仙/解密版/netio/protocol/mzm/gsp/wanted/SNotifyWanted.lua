local SNotifyWanted = class("SNotifyWanted")
SNotifyWanted.TYPEID = 12620292
function SNotifyWanted:ctor(name)
  self.id = 12620292
  self.name = name or nil
end
function SNotifyWanted:marshal(os)
  os:marshalOctets(self.name)
end
function SNotifyWanted:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SNotifyWanted:sizepolicy(size)
  return size <= 65535
end
return SNotifyWanted
