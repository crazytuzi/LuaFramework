local OctetsStream = require("netio.OctetsStream")
local ChatGiftOctets = class("ChatGiftOctets")
function ChatGiftOctets:ctor(chatGiftId, chatGiftStr)
  self.chatGiftId = chatGiftId or nil
  self.chatGiftStr = chatGiftStr or nil
end
function ChatGiftOctets:marshal(os)
  os:marshalInt64(self.chatGiftId)
  os:marshalString(self.chatGiftStr)
end
function ChatGiftOctets:unmarshal(os)
  self.chatGiftId = os:unmarshalInt64()
  self.chatGiftStr = os:unmarshalString()
end
return ChatGiftOctets
