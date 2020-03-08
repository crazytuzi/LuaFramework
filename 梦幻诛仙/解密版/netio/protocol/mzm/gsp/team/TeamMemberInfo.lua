local OctetsStream = require("netio.OctetsStream")
local TeamMemberInfo = class("TeamMemberInfo")
function TeamMemberInfo:ctor(teamMember_id, name, level, menpai, gender, status, avatarId, avatarFrameid)
  self.teamMember_id = teamMember_id or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.status = status or nil
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
end
function TeamMemberInfo:marshal(os)
  os:marshalInt64(self.teamMember_id)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.status)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
end
function TeamMemberInfo:unmarshal(os)
  self.teamMember_id = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.status = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
end
return TeamMemberInfo
