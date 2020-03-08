local CChatGiftReq = class("CChatGiftReq")
CChatGiftReq.TYPEID = 12585256
function CChatGiftReq:ctor(channelType, channelId, chatGiftType, chatGiftNum, chatGiftStr, curYuanBao)
  self.id = 12585256
  self.channelType = channelType or nil
  self.channelId = channelId or nil
  self.chatGiftType = chatGiftType or nil
  self.chatGiftNum = chatGiftNum or nil
  self.chatGiftStr = chatGiftStr or nil
  self.curYuanBao = curYuanBao or nil
end
function CChatGiftReq:marshal(os)
  os:marshalInt32(self.channelType)
  os:marshalInt64(self.channelId)
  os:marshalInt32(self.chatGiftType)
  os:marshalInt32(self.chatGiftNum)
  os:marshalString(self.chatGiftStr)
  os:marshalInt64(self.curYuanBao)
end
function CChatGiftReq:unmarshal(os)
  self.channelType = os:unmarshalInt32()
  self.channelId = os:unmarshalInt64()
  self.chatGiftType = os:unmarshalInt32()
  self.chatGiftNum = os:unmarshalInt32()
  self.chatGiftStr = os:unmarshalString()
  self.curYuanBao = os:unmarshalInt64()
end
function CChatGiftReq:sizepolicy(size)
  return size <= 65535
end
return CChatGiftReq
