local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInSingleBattleCamp = class("SChatInSingleBattleCamp")
SChatInSingleBattleCamp.TYPEID = 12585276
function SChatInSingleBattleCamp:ctor(chatContent)
  self.id = 12585276
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInSingleBattleCamp:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInSingleBattleCamp:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInSingleBattleCamp:sizepolicy(size)
  return size <= 65535
end
return SChatInSingleBattleCamp
