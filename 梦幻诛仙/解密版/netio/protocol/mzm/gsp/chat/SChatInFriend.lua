local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInFriend = class("SChatInFriend")
SChatInFriend.TYPEID = 12585280
function SChatInFriend:ctor(chatContent)
  self.id = 12585280
  self.chatContent = chatContent or ChatContent.new()
end
function SChatInFriend:marshal(os)
  self.chatContent:marshal(os)
end
function SChatInFriend:unmarshal(os)
  self.chatContent = ChatContent.new()
  self.chatContent:unmarshal(os)
end
function SChatInFriend:sizepolicy(size)
  return size <= 65535
end
return SChatInFriend
