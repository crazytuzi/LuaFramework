local OctetsStream = require("netio.OctetsStream")
local ChatContent = class("ChatContent")
function ChatContent:ctor(roleId, roleName, gender, occupationId, avatarid, avatar_frame_id, level, vipLevel, modelId, badge, contentType, content, chatBubbleCfgId, timestamp)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.avatarid = avatarid or nil
  self.avatar_frame_id = avatar_frame_id or nil
  self.level = level or nil
  self.vipLevel = vipLevel or nil
  self.modelId = modelId or nil
  self.badge = badge or {}
  self.contentType = contentType or nil
  self.content = content or nil
  self.chatBubbleCfgId = chatBubbleCfgId or nil
  self.timestamp = timestamp or nil
end
function ChatContent:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.avatarid)
  os:marshalInt32(self.avatar_frame_id)
  os:marshalInt32(self.level)
  os:marshalUInt8(self.vipLevel)
  os:marshalInt32(self.modelId)
  os:marshalCompactUInt32(table.getn(self.badge))
  for _, v in ipairs(self.badge) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.contentType)
  os:marshalOctets(self.content)
  os:marshalInt32(self.chatBubbleCfgId)
  os:marshalInt64(self.timestamp)
end
function ChatContent:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.avatarid = os:unmarshalInt32()
  self.avatar_frame_id = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.vipLevel = os:unmarshalUInt8()
  self.modelId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.badge, v)
  end
  self.contentType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
  self.chatBubbleCfgId = os:unmarshalInt32()
  self.timestamp = os:unmarshalInt64()
end
return ChatContent
