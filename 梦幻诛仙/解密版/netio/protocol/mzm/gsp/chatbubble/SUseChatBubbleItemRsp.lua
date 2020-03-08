local ChatBubbleInfo = require("netio.protocol.mzm.gsp.chatbubble.ChatBubbleInfo")
local SUseChatBubbleItemRsp = class("SUseChatBubbleItemRsp")
SUseChatBubbleItemRsp.TYPEID = 12621831
function SUseChatBubbleItemRsp:ctor(chatBubbleInfo)
  self.id = 12621831
  self.chatBubbleInfo = chatBubbleInfo or ChatBubbleInfo.new()
end
function SUseChatBubbleItemRsp:marshal(os)
  self.chatBubbleInfo:marshal(os)
end
function SUseChatBubbleItemRsp:unmarshal(os)
  self.chatBubbleInfo = ChatBubbleInfo.new()
  self.chatBubbleInfo:unmarshal(os)
end
function SUseChatBubbleItemRsp:sizepolicy(size)
  return size <= 65535
end
return SUseChatBubbleItemRsp
