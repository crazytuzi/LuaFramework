local OctetsStream = require("netio.OctetsStream")
local GetChatGiftSimpleInfo = class("GetChatGiftSimpleInfo")
function GetChatGiftSimpleInfo:ctor(chatGiftId, roleName, chatGiftStr, isCanGet)
  self.chatGiftId = chatGiftId or nil
  self.roleName = roleName or nil
  self.chatGiftStr = chatGiftStr or nil
  self.isCanGet = isCanGet or nil
end
function GetChatGiftSimpleInfo:marshal(os)
  os:marshalInt64(self.chatGiftId)
  os:marshalString(self.roleName)
  os:marshalString(self.chatGiftStr)
  os:marshalInt32(self.isCanGet)
end
function GetChatGiftSimpleInfo:unmarshal(os)
  self.chatGiftId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.chatGiftStr = os:unmarshalString()
  self.isCanGet = os:unmarshalInt32()
end
return GetChatGiftSimpleInfo
