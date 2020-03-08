local SPutOffChatBubbleRsp = class("SPutOffChatBubbleRsp")
SPutOffChatBubbleRsp.TYPEID = 12621828
function SPutOffChatBubbleRsp:ctor(chatBubbleCfgId)
  self.id = 12621828
  self.chatBubbleCfgId = chatBubbleCfgId or nil
end
function SPutOffChatBubbleRsp:marshal(os)
  os:marshalInt32(self.chatBubbleCfgId)
end
function SPutOffChatBubbleRsp:unmarshal(os)
  self.chatBubbleCfgId = os:unmarshalInt32()
end
function SPutOffChatBubbleRsp:sizepolicy(size)
  return size <= 65535
end
return SPutOffChatBubbleRsp
