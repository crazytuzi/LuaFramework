local OctetsStream = require("netio.OctetsStream")
local StrangerInfo = class("StrangerInfo")
function StrangerInfo:ctor(roleId, roleName, roleLevel, occupationId, sex, applyTime, content, avatarId, avatarFrameId)
  self.roleId = roleId or nil
  self.roleName = roleName or nil
  self.roleLevel = roleLevel or nil
  self.occupationId = occupationId or nil
  self.sex = sex or nil
  self.applyTime = applyTime or nil
  self.content = content or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
end
function StrangerInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalString(self.roleName)
  os:marshalInt32(self.roleLevel)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.sex)
  os:marshalInt32(self.applyTime)
  os:marshalString(self.content)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
end
function StrangerInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.roleName = os:unmarshalString()
  self.roleLevel = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.sex = os:unmarshalInt32()
  self.applyTime = os:unmarshalInt32()
  self.content = os:unmarshalString()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
end
return StrangerInfo
