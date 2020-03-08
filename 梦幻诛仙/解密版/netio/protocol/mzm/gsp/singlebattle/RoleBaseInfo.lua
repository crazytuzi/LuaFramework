local OctetsStream = require("netio.OctetsStream")
local RoleBaseInfo = class("RoleBaseInfo")
RoleBaseInfo.STATE_NORMAL = 1
RoleBaseInfo.STATE_OUTLINE = 2
RoleBaseInfo.STATE_LEAVE = 3
function RoleBaseInfo:ctor(name, gender, occupation, level, avatarId, zoneId, state, num, avatarFrameid)
  self.name = name or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.level = level or nil
  self.avatarId = avatarId or nil
  self.zoneId = zoneId or nil
  self.state = state or nil
  self.num = num or nil
  self.avatarFrameid = avatarFrameid or nil
end
function RoleBaseInfo:marshal(os)
  os:marshalOctets(self.name)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.level)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.zoneId)
  os:marshalInt32(self.state)
  os:marshalInt32(self.num)
  os:marshalInt32(self.avatarFrameid)
end
function RoleBaseInfo:unmarshal(os)
  self.name = os:unmarshalOctets()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.zoneId = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
end
return RoleBaseInfo
