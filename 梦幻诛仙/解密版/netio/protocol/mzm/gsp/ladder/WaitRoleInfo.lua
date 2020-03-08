local OctetsStream = require("netio.OctetsStream")
local WaitRoleInfo = class("WaitRoleInfo")
function WaitRoleInfo:ctor(gender, occupation, avatarId, avatarFrameId, level, name, stage, matchScore, roleid, winCount, loseCount, fightScore)
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.level = level or nil
  self.name = name or nil
  self.stage = stage or nil
  self.matchScore = matchScore or nil
  self.roleid = roleid or nil
  self.winCount = winCount or nil
  self.loseCount = loseCount or nil
  self.fightScore = fightScore or nil
end
function WaitRoleInfo:marshal(os)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalInt32(self.level)
  os:marshalString(self.name)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.matchScore)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.winCount)
  os:marshalInt32(self.loseCount)
  os:marshalInt32(self.fightScore)
end
function WaitRoleInfo:unmarshal(os)
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.stage = os:unmarshalInt32()
  self.matchScore = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.winCount = os:unmarshalInt32()
  self.loseCount = os:unmarshalInt32()
  self.fightScore = os:unmarshalInt32()
end
return WaitRoleInfo
