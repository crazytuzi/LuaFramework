local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInAnchor = class("SChatInAnchor")
SChatInAnchor.TYPEID = 12585240
function SChatInAnchor:ctor(roomType, chatContent)
  self.id = 12585240
  self.roomType = roomType or nil
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInAnchor:marshal(os)
  os:marshalInt32(self.roomType)
  self.chatContent:marshal(os)
end
function SChatInAnchor:unmarshal(os)
  self.roomType = os:unmarshalInt32()
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInAnchor:sizepolicy(size)
  return size <= 65535
end
return SChatInAnchor
