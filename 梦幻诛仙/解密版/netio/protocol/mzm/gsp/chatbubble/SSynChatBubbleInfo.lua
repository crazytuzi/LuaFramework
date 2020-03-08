local SSynChatBubbleInfo = class("SSynChatBubbleInfo")
SSynChatBubbleInfo.TYPEID = 12621833
function SSynChatBubbleInfo:ctor(chatBubbleInfos)
  self.id = 12621833
  self.chatBubbleInfos = chatBubbleInfos or {}
end
function SSynChatBubbleInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.chatBubbleInfos))
  for _, v in ipairs(self.chatBubbleInfos) do
    v:marshal(os)
  end
end
function SSynChatBubbleInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chatbubble.ChatBubbleInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.chatBubbleInfos, v)
  end
end
function SSynChatBubbleInfo:sizepolicy(size)
  return size <= 65535
end
return SSynChatBubbleInfo
