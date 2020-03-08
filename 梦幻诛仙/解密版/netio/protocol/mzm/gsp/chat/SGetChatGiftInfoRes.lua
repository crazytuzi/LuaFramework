local ChatGiftInfo = require("netio.protocol.mzm.gsp.chat.ChatGiftInfo")
local SGetChatGiftInfoRes = class("SGetChatGiftInfoRes")
SGetChatGiftInfoRes.TYPEID = 12585259
function SGetChatGiftInfoRes:ctor(chatGiftInfo)
  self.id = 12585259
  self.chatGiftInfo = chatGiftInfo or ChatGiftInfo.new()
end
function SGetChatGiftInfoRes:marshal(os)
  self.chatGiftInfo:marshal(os)
end
function SGetChatGiftInfoRes:unmarshal(os)
  self.chatGiftInfo = ChatGiftInfo.new()
  self.chatGiftInfo:unmarshal(os)
end
function SGetChatGiftInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetChatGiftInfoRes
