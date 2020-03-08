local SDelCommandReq = class("SDelCommandReq")
SDelCommandReq.TYPEID = 12594204
function SDelCommandReq:ctor(commandType, commandIndex)
  self.id = 12594204
  self.commandType = commandType or nil
  self.commandIndex = commandIndex or nil
end
function SDelCommandReq:marshal(os)
  os:marshalInt32(self.commandType)
  os:marshalInt32(self.commandIndex)
end
function SDelCommandReq:unmarshal(os)
  self.commandType = os:unmarshalInt32()
  self.commandIndex = os:unmarshalInt32()
end
function SDelCommandReq:sizepolicy(size)
  return size <= 65535
end
return SDelCommandReq
