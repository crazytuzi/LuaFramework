local PortForward = class("PortForward")
PortForward.TYPEID = 109
function PortForward:ctor(command, portsid, code, data)
  self.id = 109
  self.command = command or nil
  self.portsid = portsid or nil
  self.code = code or nil
  self.data = data or nil
end
function PortForward:marshal(os)
  os:marshalInt32(self.command)
  os:marshalOctets(self.portsid)
  os:marshalInt32(self.code)
  os:marshalOctets(self.data)
end
function PortForward:unmarshal(os)
  self.command = os:unmarshalInt32()
  self.portsid = os:unmarshalOctets()
  self.code = os:unmarshalInt32()
  self.data = os:unmarshalOctets()
end
function PortForward:sizepolicy(size)
  return size <= 65536
end
return PortForward
