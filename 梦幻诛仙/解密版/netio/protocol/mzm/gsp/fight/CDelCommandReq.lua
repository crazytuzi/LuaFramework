local CDelCommandReq = class("CDelCommandReq")
CDelCommandReq.TYPEID = 12594203
function CDelCommandReq:ctor(commandType, commandIndex)
  self.id = 12594203
  self.commandType = commandType or nil
  self.commandIndex = commandIndex or nil
end
function CDelCommandReq:marshal(os)
  os:marshalInt32(self.commandType)
  os:marshalInt32(self.commandIndex)
end
function CDelCommandReq:unmarshal(os)
  self.commandType = os:unmarshalInt32()
  self.commandIndex = os:unmarshalInt32()
end
function CDelCommandReq:sizepolicy(size)
  return size <= 65535
end
return CDelCommandReq
