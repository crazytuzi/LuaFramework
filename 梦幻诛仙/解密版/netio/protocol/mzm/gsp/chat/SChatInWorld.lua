local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInWorld = class("SChatInWorld")
SChatInWorld.TYPEID = 12585237
function SChatInWorld:ctor(chatContent)
  self.id = 12585237
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInWorld:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInWorld:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInWorld:sizepolicy(size)
  return size <= 65535
end
return SChatInWorld
