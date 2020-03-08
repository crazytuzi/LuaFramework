local SSyncGetChatGiftMoreMoney = class("SSyncGetChatGiftMoreMoney")
SSyncGetChatGiftMoreMoney.TYPEID = 12585270
function SSyncGetChatGiftMoreMoney:ctor(chatGiftId, channelType, channelId, sendRoleName, getRoleName)
  self.id = 12585270
  self.chatGiftId = chatGiftId or nil
  self.channelType = channelType or nil
  self.channelId = channelId or nil
  self.sendRoleName = sendRoleName or nil
  self.getRoleName = getRoleName or nil
end
function SSyncGetChatGiftMoreMoney:marshal(os)
  os:marshalInt64(self.chatGiftId)
  os:marshalInt32(self.channelType)
  os:marshalInt64(self.channelId)
  os:marshalString(self.sendRoleName)
  os:marshalString(self.getRoleName)
end
function SSyncGetChatGiftMoreMoney:unmarshal(os)
  self.chatGiftId = os:unmarshalInt64()
  self.channelType = os:unmarshalInt32()
  self.channelId = os:unmarshalInt64()
  self.sendRoleName = os:unmarshalString()
  self.getRoleName = os:unmarshalString()
end
function SSyncGetChatGiftMoreMoney:sizepolicy(size)
  return size <= 65535
end
return SSyncGetChatGiftMoreMoney
