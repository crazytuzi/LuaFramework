local SSynCommandRes = class("SSynCommandRes")
SSynCommandRes.TYPEID = 12594200
function SSynCommandRes:ctor(commandName, commandFighterid, beCommandedFighterid)
  self.id = 12594200
  self.commandName = commandName or nil
  self.commandFighterid = commandFighterid or nil
  self.beCommandedFighterid = beCommandedFighterid or nil
end
function SSynCommandRes:marshal(os)
  os:marshalString(self.commandName)
  os:marshalInt32(self.commandFighterid)
  os:marshalInt32(self.beCommandedFighterid)
end
function SSynCommandRes:unmarshal(os)
  self.commandName = os:unmarshalString()
  self.commandFighterid = os:unmarshalInt32()
  self.beCommandedFighterid = os:unmarshalInt32()
end
function SSynCommandRes:sizepolicy(size)
  return size <= 65535
end
return SSynCommandRes
