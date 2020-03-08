local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local TeamMember = class("TeamMember")
TeamMember.ST_NORMAL = 0
TeamMember.ST_TMP_LEAVE = 1
TeamMember.ST_OFFLINE = 2
TeamMember.ST_TO_BE_TMP_LEAVE = 4
TeamMember.ST_TO_BE_LEAVE = 5
TeamMember.ST_TO_BE_RETURN = 6
function TeamMember:ctor(roleid, name, level, menpai, gender, status, friendSetting, model, avatarId, avatarFrameid)
  self.roleid = roleid or nil
  self.name = name or nil
  self.level = level or nil
  self.menpai = menpai or nil
  self.gender = gender or nil
  self.status = status or nil
  self.friendSetting = friendSetting or nil
  self.model = model or ModelInfo.new()
  self.avatarId = avatarId or nil
  self.avatarFrameid = avatarFrameid or nil
end
function TeamMember:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.level)
  os:marshalInt32(self.menpai)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.status)
  os:marshalInt32(self.friendSetting)
  self.model:marshal(os)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameid)
end
function TeamMember:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.menpai = os:unmarshalInt32()
  self.gender = os:unmarshalInt32()
  self.status = os:unmarshalInt32()
  self.friendSetting = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameid = os:unmarshalInt32()
end
return TeamMember
