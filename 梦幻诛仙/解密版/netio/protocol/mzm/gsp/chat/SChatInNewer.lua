local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInNewer = class("SChatInNewer")
SChatInNewer.TYPEID = 12585227
function SChatInNewer:ctor(chatContent)
  self.id = 12585227
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInNewer:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInNewer:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInNewer:sizepolicy(size)
  return size <= 65535
end
return SChatInNewer
