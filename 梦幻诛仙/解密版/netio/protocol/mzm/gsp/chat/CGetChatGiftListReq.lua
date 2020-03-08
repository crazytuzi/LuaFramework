local CGetChatGiftListReq = class("CGetChatGiftListReq")
CGetChatGiftListReq.TYPEID = 12585257
function CGetChatGiftListReq:ctor(chatGiftType)
  self.id = 12585257
  self.chatGiftType = chatGiftType or nil
end
function CGetChatGiftListReq:marshal(os)
  os:marshalInt32(self.chatGiftType)
end
function CGetChatGiftListReq:unmarshal(os)
  self.chatGiftType = os:unmarshalInt32()
end
function CGetChatGiftListReq:sizepolicy(size)
  return size <= 65535
end
return CGetChatGiftListReq
