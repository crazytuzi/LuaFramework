local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInMap = class("SChatInMap")
SChatInMap.TYPEID = 12585222
function SChatInMap:ctor(chatContent)
  self.id = 12585222
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInMap:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInMap:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInMap:sizepolicy(size)
  return size <= 65535
end
return SChatInMap
