local SNotifyChatBubbleExpire = class("SNotifyChatBubbleExpire")
SNotifyChatBubbleExpire.TYPEID = 12621830
function SNotifyChatBubbleExpire:ctor(chatBubbleCfgId)
  self.id = 12621830
  self.chatBubbleCfgId = chatBubbleCfgId or nil
end
function SNotifyChatBubbleExpire:marshal(os)
  os:marshalInt32(self.chatBubbleCfgId)
end
function SNotifyChatBubbleExpire:unmarshal(os)
  self.chatBubbleCfgId = os:unmarshalInt32()
end
function SNotifyChatBubbleExpire:sizepolicy(size)
  return size <= 65535
end
return SNotifyChatBubbleExpire
