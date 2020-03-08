local ServerIDResponse = class("ServerIDResponse")
ServerIDResponse.TYPEID = 8902
function ServerIDResponse:ctor(platType, serverIds)
  self.id = 8902
  self.platType = platType or nil
  self.serverIds = serverIds or nil
end
function ServerIDResponse:marshal(os)
  os:marshalInt32(self.platType)
  os:marshalOctets(self.serverIds)
end
function ServerIDResponse:unmarshal(os)
  self.platType = os:unmarshalInt32()
  self.serverIds = os:unmarshalOctets()
end
function ServerIDResponse:sizepolicy(size)
  return size <= 512
end
return ServerIDResponse
