local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInRoom = class("SChatInRoom")
SChatInRoom.TYPEID = 12585247
function SChatInRoom:ctor(sender_zoneId, content)
  self.id = 12585247
  self.sender_zoneId = sender_zoneId or nil
  self.content = content or ChatContent.new()
end
function SChatInRoom:marshal(os)
  os:marshalInt32(self.sender_zoneId)
  self.content:marshal(os)
end
function SChatInRoom:unmarshal(os)
  self.sender_zoneId = os:unmarshalInt32()
  self.content = ChatContent.new()
  self.content:unmarshal(os)
end
function SChatInRoom:sizepolicy(size)
  return size <= 65535
end
return SChatInRoom
