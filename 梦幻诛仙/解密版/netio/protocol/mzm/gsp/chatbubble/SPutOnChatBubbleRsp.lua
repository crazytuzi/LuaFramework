local SPutOnChatBubbleRsp = class("SPutOnChatBubbleRsp")
SPutOnChatBubbleRsp.TYPEID = 12621825
function SPutOnChatBubbleRsp:ctor(chatBubbleCfgId)
  self.id = 12621825
  self.chatBubbleCfgId = chatBubbleCfgId or nil
end
function SPutOnChatBubbleRsp:marshal(os)
  os:marshalInt32(self.chatBubbleCfgId)
end
function SPutOnChatBubbleRsp:unmarshal(os)
  self.chatBubbleCfgId = os:unmarshalInt32()
end
function SPutOnChatBubbleRsp:sizepolicy(size)
  return size <= 65535
end
return SPutOnChatBubbleRsp
