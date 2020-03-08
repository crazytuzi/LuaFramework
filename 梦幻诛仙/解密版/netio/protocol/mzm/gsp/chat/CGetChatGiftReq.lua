local CGetChatGiftReq = class("CGetChatGiftReq")
CGetChatGiftReq.TYPEID = 12585260
function CGetChatGiftReq:ctor(channelType, chatGiftId)
  self.id = 12585260
  self.channelType = channelType or nil
  self.chatGiftId = chatGiftId or nil
end
function CGetChatGiftReq:marshal(os)
  os:marshalInt32(self.channelType)
  os:marshalInt64(self.chatGiftId)
end
function CGetChatGiftReq:unmarshal(os)
  self.channelType = os:unmarshalInt32()
  self.chatGiftId = os:unmarshalInt64()
end
function CGetChatGiftReq:sizepolicy(size)
  return size <= 65535
end
return CGetChatGiftReq
