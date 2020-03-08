local SNotifyNPCStartWanted = class("SNotifyNPCStartWanted")
SNotifyNPCStartWanted.TYPEID = 12620290
function SNotifyNPCStartWanted:ctor(roleName)
  self.id = 12620290
  self.roleName = roleName or nil
end
function SNotifyNPCStartWanted:marshal(os)
  os:marshalOctets(self.roleName)
end
function SNotifyNPCStartWanted:unmarshal(os)
  self.roleName = os:unmarshalOctets()
end
function SNotifyNPCStartWanted:sizepolicy(size)
  return size <= 65535
end
return SNotifyNPCStartWanted
