local SSyncGetChatGiftRes = class("SSyncGetChatGiftRes")
SSyncGetChatGiftRes.TYPEID = 12585261
function SSyncGetChatGiftRes:ctor(channelType, channelId, chatGiftId, roleId, roleName, getRoleId, getRoleName)
  self.id = 12585261
  self.channelType = channelType or nil
  self.channelId = channelId or nil
  self.chatGiftId = chatGiftId or nil
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.getRoleId = getRoleId or nil
  self.getRoleName = getRoleName or nil
end
function SSyncGetChatGiftRes:marshal(os)
  os:marshalInt32(self.channelType)
  os:marshalInt64(self.channelId)
  os:marshalInt64(self.chatGiftId)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt64(self.getRoleId)
  os:marshalString(self.getRoleName)
end
function SSyncGetChatGiftRes:unmarshal(os)
  self.channelType = os:unmarshalInt32()
  self.channelId = os:unmarshalInt64()
  self.chatGiftId = os:unmarshalInt64()
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.getRoleId = os:unmarshalInt64()
  self.getRoleName = os:unmarshalString()
end
function SSyncGetChatGiftRes:sizepolicy(size)
  return size <= 65535
end
return SSyncGetChatGiftRes
