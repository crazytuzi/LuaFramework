local OctetsStream = require("netio.OctetsStream")
local CorpsMember = class("CorpsMember")
function CorpsMember:ctor(roleId, name, level, occupationId, avatarId, avatarFrameId, duty, gender, joinTime, offlineTime)
  self.roleId = roleId or nil
  self.name = name or nil
  self.level = level or nil
  self.occupationId = occupationId or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.duty = duty or nil
  self.gender = gender or nil
  self.joinTime = joinTime or nil
  self.offlineTime = offlineTime or nil
end
function CorpsMember:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalInt32(self.duty)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.joinTime)
  os:marshalInt32(self.offlineTime)
end
function CorpsMember:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.level = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.duty = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.joinTime = os:unmarshalInt32()
  self.offlineTime = os:unmarshalInt32()
end
return CorpsMember
