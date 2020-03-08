local CChatMessage = class("CChatMessage")
CChatMessage.TYPEID = 12585731
function CChatMessage:ctor(command)
  self.id = 12585731
  self.command = command or nil
end
function CChatMessage:marshal(os)
  os:marshalString(self.command)
end
function CChatMessage:unmarshal(os)
  self.command = os:unmarshalString()
end
function CChatMessage:sizepolicy(size)
  return size <= 65535
end
return CChatMessage
