local OctetsStream = require("netio.OctetsStream")
local ChatGiftInfo = class("ChatGiftInfo")
function ChatGiftInfo:ctor(roleId, roleLevel, menpai, gender, avatarid, avatar_frame_id, chatGiftId, roleName, chatGiftStr, getChatGiftInfo, chatGiftNum, chatGiftType)
  self.roleId = roleId or nil
  self.roleLevel = roleLevel or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
  self.chatGiftId = chatGiftId or nil
  self.roleName = roleName or nil
  self.chatGiftStr = chatGiftStr or nil
  self.getChatGiftInfo = getChatGiftInfo or {}
  self.chatGiftNum = chatGiftNum or nil
  self.chatGiftType = chatGiftType or nil
end
function ChatGiftInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.roleLevel)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
  os:marshalInt64(self.chatGiftId)
  os:marshalString(self.roleName)
  os:marshalString(self.chatGiftStr)
  os:marshalCompactUInt32(table.getn(self.getChatGiftInfo))
  for _, v in ipairs(self.getChatGiftInfo) do
    v:marshal(os)
  end
  os:marshalInt32(self.chatGiftNum)
  os:marshalInt32(self.chatGiftType)
end
function ChatGiftInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleLevel = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
  self.chatGiftId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.chatGiftStr = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.chat.GetChatGiftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.getChatGiftInfo, v)
  end
  self.chatGiftNum = os:unmarshalInt32()
  self.chatGiftType = os:unmarshalInt32()
end
return ChatGiftInfo
