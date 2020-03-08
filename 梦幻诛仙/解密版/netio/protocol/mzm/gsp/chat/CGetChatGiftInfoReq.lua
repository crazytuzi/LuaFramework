local CGetChatGiftInfoReq = class("CGetChatGiftInfoReq")
CGetChatGiftInfoReq.TYPEID = 12585255
function CGetChatGiftInfoReq:ctor(chatGiftId, channelType)
  self.id = 12585255
  self.chatGiftId = chatGiftId or nil
  self.channelType = channelType or nil
end
function CGetChatGiftInfoReq:marshal(os)
  os:marshalInt64(self.chatGiftId)
  os:marshalInt32(self.channelType)
end
function CGetChatGiftInfoReq:unmarshal(os)
  self.chatGiftId = os:unmarshalInt64()
  self.channelType = os:unmarshalInt32()
end
function CGetChatGiftInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetChatGiftInfoReq
