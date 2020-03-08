local CPutOffChatBubbleReq = class("CPutOffChatBubbleReq")
CPutOffChatBubbleReq.TYPEID = 12621826
function CPutOffChatBubbleReq:ctor()
  self.id = 12621826
end
function CPutOffChatBubbleReq:marshal(os)
end
function CPutOffChatBubbleReq:unmarshal(os)
end
function CPutOffChatBubbleReq:sizepolicy(size)
  return size <= 65535
end
return CPutOffChatBubbleReq
