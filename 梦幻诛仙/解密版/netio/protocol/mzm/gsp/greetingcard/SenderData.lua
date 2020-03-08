local OctetsStream = require("netio.OctetsStream")
local SenderData = class("SenderData")
function SenderData:ctor(roleId, roleName, gender, occupationId, level, modelId, badge, avatarId, avatarFrameId)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.gender = gender or nil
  self.occupationId = occupationId or nil
  self.level = level or nil
  self.modelId = modelId or nil
  self.badge = badge or {}
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function SenderData:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.level)
  os:marshalInt32(self.modelId)
  os:marshalCompactUInt32(table.getn(self.badge))
  for _, v in ipairs(self.badge) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function SenderData:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.modelId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.badge, v)
  end
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return SenderData
