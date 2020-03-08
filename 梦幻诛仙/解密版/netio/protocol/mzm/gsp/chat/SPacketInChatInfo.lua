local SPacketInChatInfo = class("SPacketInChatInfo")
SPacketInChatInfo.TYPEID = 12585229
function SPacketInChatInfo:ctor(checkedroleid, packettype, checkInfo)
  self.id = 12585229
  self.checkedroleid = checkedroleid or nil
  self.packettype = packettype or nil
  self.checkInfo = checkInfo or nil
end
function SPacketInChatInfo:marshal(os)
  os:marshalInt64(self.checkedroleid)
  os:marshalInt32(self.packettype)
  os:marshalOctets(self.checkInfo)
end
function SPacketInChatInfo:unmarshal(os)
  self.checkedroleid = os:unmarshalInt64()
  self.packettype = os:unmarshalInt32()
  self.checkInfo = os:unmarshalOctets()
end
function SPacketInChatInfo:sizepolicy(size)
  return size <= 65535
end
return SPacketInChatInfo
