local OctetsStream = require("netio.OctetsStream")
local PrisonRoleInfo = class("PrisonRoleInfo")
function PrisonRoleInfo:ctor(roleId, name, avatarId, gender, menpai, level, endTimeStamp, avatarFrameId)
  self.roleId = roleId or nil
  self.name = name or nil
  self.avatarId = avatarId or nil
  self.gender = gender or nil
  self.menpai = menpai or nil
  self.level = level or nil
  self.endTimeStamp = endTimeStamp or nil
  self.avatarFrameId = avatarFrameId or nil
end
function PrisonRoleInfo:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.level)
  os:marshalInt64(self.endTimeStamp)
  os:marshalInt32(self.avatarFrameId)
end
function PrisonRoleInfo:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.avatarId = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.endTimeStamp = os:unmarshalInt64()
  self.avatarFrameId = os:unmarshalInt32()
end
return PrisonRoleInfo
