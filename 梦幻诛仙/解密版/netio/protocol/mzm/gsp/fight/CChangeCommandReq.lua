local CChangeCommandReq = class("CChangeCommandReq")
CChangeCommandReq.TYPEID = 12594198
function CChangeCommandReq:ctor(commandType, commandIndex, commandName)
  self.id = 12594198
  self.commandType = commandType or nil
  self.commandIndex = commandIndex or nil
  self.commandName = commandName or nil
end
function CChangeCommandReq:marshal(os)
  os:marshalInt32(self.commandType)
  os:marshalInt32(self.commandIndex)
  os:marshalString(self.commandName)
end
function CChangeCommandReq:unmarshal(os)
  self.commandType = os:unmarshalInt32()
  self.commandIndex = os:unmarshalInt32()
  self.commandName = os:unmarshalString()
end
function CChangeCommandReq:sizepolicy(size)
  return size <= 65535
end
return CChangeCommandReq
