local SSynLastMourn = class("SSynLastMourn")
SSynLastMourn.TYPEID = 12613377
function SSynLastMourn:ctor(state)
  self.id = 12613377
  self.state = state or nil
end
function SSynLastMourn:marshal(os)
  os:marshalInt32(self.state)
end
function SSynLastMourn:unmarshal(os)
  self.state = os:unmarshalInt32()
end
function SSynLastMourn:sizepolicy(size)
  return size <= 65535
end
return SSynLastMourn
