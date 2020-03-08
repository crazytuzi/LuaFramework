local SRenameCropsBro = class("SRenameCropsBro")
SRenameCropsBro.TYPEID = 12617492
function SRenameCropsBro:ctor(name)
  self.id = 12617492
  self.name = name or nil
end
function SRenameCropsBro:marshal(os)
  os:marshalOctets(self.name)
end
function SRenameCropsBro:unmarshal(os)
  self.name = os:unmarshalOctets()
end
function SRenameCropsBro:sizepolicy(size)
  return size <= 65535
end
return SRenameCropsBro
