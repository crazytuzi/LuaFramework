local OctetsStream = require("netio.OctetsStream")
local PacketInfo = class("PacketInfo")
function PacketInfo:ctor(packetid)
  self.packetid = packetid or nil
end
function PacketInfo:marshal(os)
  os:marshalInt64(self.packetid)
end
function PacketInfo:unmarshal(os)
  self.packetid = os:unmarshalInt64()
end
return PacketInfo
