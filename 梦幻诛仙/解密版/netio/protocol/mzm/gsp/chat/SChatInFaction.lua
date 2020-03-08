local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInFaction = class("SChatInFaction")
SChatInFaction.TYPEID = 12585233
function SChatInFaction:ctor(chatContent, position)
  self.id = 12585233
  self.chatContent = chatContent or ChatContent.new()
  self.position = position or nil
end
function SChatInFaction:marshal(os)
  self.chatContent:marshal(os)
  os:marshalInt32(self.position)
end
function SChatInFaction:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
  self.position = os:unmarshalInt32()
end
function SChatInFaction:sizepolicy(size)
  return size <= 65535
end
return SChatInFaction
