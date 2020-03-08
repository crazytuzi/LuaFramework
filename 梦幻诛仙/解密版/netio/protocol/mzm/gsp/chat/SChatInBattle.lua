local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInBattle = class("SChatInBattle")
SChatInBattle.TYPEID = 12585235
function SChatInBattle:ctor(chatContent)
  self.id = 12585235
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInBattle:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInBattle:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInBattle:sizepolicy(size)
  return size <= 65535
end
return SChatInBattle
