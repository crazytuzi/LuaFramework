local OctetsStream = require("netio.OctetsStream")
local Applicant = class("Applicant")
function Applicant:ctor(roleId, level, name, occupationId, gender, avatarId, avatar_frame, time, inviterName)
  self.roleId = roleId or nil
  self.level = level or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.gender = gender or nil
  self.avatarId = avatarId or nil
  self.avatar_frame = avatar_frame or nil
  self.time = time or nil
  self.inviterName = inviterName or nil
end
function Applicant:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.level)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatar_frame)
  os:marshalInt64(self.time)
  os:marshalString(self.inviterName)
end
function Applicant:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatar_frame = os:unmarshalInt32()
  self.time = os:unmarshalInt64()
  self.inviterName = os:unmarshalString()
end
return Applicant
