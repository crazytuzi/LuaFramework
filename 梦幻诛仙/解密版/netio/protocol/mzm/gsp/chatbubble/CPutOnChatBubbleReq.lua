local CPutOnChatBubbleReq = class("CPutOnChatBubbleReq")
CPutOnChatBubbleReq.TYPEID = 12621832
function CPutOnChatBubbleReq:ctor(chatBubbleCfgId)
  self.id = 12621832
  self.chatBubbleCfgId = chatBubbleCfgId or nil
end
function CPutOnChatBubbleReq:marshal(os)
  os:marshalInt32(self.chatBubbleCfgId)
end
function CPutOnChatBubbleReq:unmarshal(os)
  self.chatBubbleCfgId = os:unmarshalInt32()
end
function CPutOnChatBubbleReq:sizepolicy(size)
  return size <= 65535
end
return CPutOnChatBubbleReq
