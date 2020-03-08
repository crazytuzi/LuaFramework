local ChatGiftOctets = require("netio.protocol.mzm.gsp.chat.ChatGiftOctets")
local SChatGiftRes = class("SChatGiftRes")
SChatGiftRes.TYPEID = 12585264
function SChatGiftRes:ctor(chatgiftoctest)
  self.id = 12585264
  self.chatgiftoctest = chatgiftoctest or ChatGiftOctets.new()
end
function SChatGiftRes:marshal(os)
  self.chatgiftoctest:marshal(os)
end
function SChatGiftRes:unmarshal(os)
  self.chatgiftoctest = ChatGiftOctets.new()
  self.chatgiftoctest:unmarshal(os)
end
function SChatGiftRes:sizepolicy(size)
  return size <= 65535
end
return SChatGiftRes
