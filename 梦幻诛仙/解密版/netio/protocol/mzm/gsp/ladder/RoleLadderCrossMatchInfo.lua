local OctetsStream = require("netio.OctetsStream")
local RoleLadderCrossMatchInfo = class("RoleLadderCrossMatchInfo")
RoleLadderCrossMatchInfo.BEGIN = 0
RoleLadderCrossMatchInfo.GEN_TOKEN_SUC = 1
RoleLadderCrossMatchInfo.TRANSFOR_DATA_SUC = 2
RoleLadderCrossMatchInfo.LOGIN = 3
function RoleLadderCrossMatchInfo:ctor(process, gender, occupation, avatarId, avatarFrameId, level, name, stage, matchScore, roleid, winCount, loseCount)
  self.process = process or nil
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
end
function RoleLadderCrossMatchInfo:marshal(os)
  os:marshalInt32(self.process)
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
end
function RoleLadderCrossMatchInfo:unmarshal(os)
  self.process = os:unmarshalInt32()
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
end
return RoleLadderCrossMatchInfo
