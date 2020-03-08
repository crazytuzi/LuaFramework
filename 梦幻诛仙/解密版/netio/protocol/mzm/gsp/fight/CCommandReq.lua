local CCommandReq = class("CCommandReq")
CCommandReq.TYPEID = 12594199
function CCommandReq:ctor(commandType, commandName, fighterid)
  self.id = 12594199
  self.commandType = commandType or nil
  self.commandName = commandName or nil
  self.fighterid = fighterid or nil
end
function CCommandReq:marshal(os)
  os:marshalInt32(self.commandType)
  os:marshalString(self.commandName)
  os:marshalInt32(self.fighterid)
end
function CCommandReq:unmarshal(os)
  self.commandType = os:unmarshalInt32()
  self.commandName = os:unmarshalString()
  self.fighterid = os:unmarshalInt32()
end
function CCommandReq:sizepolicy(size)
  return size <= 65535
end
return CCommandReq
