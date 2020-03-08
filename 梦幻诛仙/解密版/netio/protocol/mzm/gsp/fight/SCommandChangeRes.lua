local SCommandChangeRes = class("SCommandChangeRes")
SCommandChangeRes.TYPEID = 12594196
function SCommandChangeRes:ctor(commandType, commandIndex, commandName)
  self.id = 12594196
  self.commandType = commandType or nil
  self.commandIndex = commandIndex or nil
  self.commandName = commandName or nil
end
function SCommandChangeRes:marshal(os)
  os:marshalInt32(self.commandType)
  os:marshalInt32(self.commandIndex)
  os:marshalString(self.commandName)
end
function SCommandChangeRes:unmarshal(os)
  self.commandType = os:unmarshalInt32()
  self.commandIndex = os:unmarshalInt32()
  self.commandName = os:unmarshalString()
end
function SCommandChangeRes:sizepolicy(size)
  return size <= 65535
end
return SCommandChangeRes
