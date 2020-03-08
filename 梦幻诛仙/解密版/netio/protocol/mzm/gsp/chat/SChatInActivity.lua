local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInActivity = class("SChatInActivity")
SChatInActivity.TYPEID = 12585234
function SChatInActivity:ctor(chatContent)
  self.id = 12585234
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInActivity:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInActivity:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInActivity:sizepolicy(size)
  return size <= 65535
end
return SChatInActivity
