local CGMCommand = class("CGMCommand")
CGMCommand.TYPEID = 12585733
function CGMCommand:ctor(command)
  self.id = 12585733
  self.command = command or nil
end
function CGMCommand:marshal(os)
  os:marshalString(self.command)
end
function CGMCommand:unmarshal(os)
  self.command = os:unmarshalString()
end
function CGMCommand:sizepolicy(size)
  return size <= 65535
end
return CGMCommand
