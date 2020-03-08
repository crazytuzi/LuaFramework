local PacketInfo = require("netio.protocol.mzm.gsp.chat.PacketInfo")
local CPacketInChat = class("CPacketInChat")
CPacketInChat.TYPEID = 12585226
function CPacketInChat:ctor(checkedroleid, packettype, packetinfo)
  self.id = 12585226
  self.checkedroleid = checkedroleid or nil
  self.packettype = packettype or nil
  self.packetinfo = packetinfo or PacketInfo.new()
end
function CPacketInChat:marshal(os)
  os:marshalInt64(self.checkedroleid)
  os:marshalInt32(self.packettype)
  self.packetinfo:marshal(os)
end
function CPacketInChat:unmarshal(os)
  self.checkedroleid = os:unmarshalInt64()
  self.packettype = os:unmarshalInt32()
  self.packetinfo = PacketInfo.new()
  self.packetinfo:unmarshal(os)
end
function CPacketInChat:sizepolicy(size)
  return size <= 65535
end
return CPacketInChat
