local OctetsStream = require("netio.OctetsStream")
local LevelCfg = require("netio.protocol.mzm.gsp.teamplatform.LevelCfg")
local MatchCfg = require("netio.protocol.mzm.gsp.teamplatform.MatchCfg")
local TeamInfo = class("TeamInfo")
function TeamInfo:ctor(teamId, leaderId, teamLeaderName, teamLeaderOccupation, teamLeaderSex, teamLeaderLevel, avatarId, avatarFrameId, chatBubbleCfgId, level, activityCfg, num)
  self.teamId = teamId or nil
  self.leaderId = leaderId or nil
  self.teamLeaderName = teamLeaderName or nil
  self.teamLeaderOccupation = teamLeaderOccupation or nil
  self.teamLeaderSex = teamLeaderSex or nil
  self.teamLeaderLevel = teamLeaderLevel or nil
  self.avatarId = avatarId or nil
  self.avatarFrameId = avatarFrameId or nil
  self.chatBubbleCfgId = chatBubbleCfgId or nil
  self.level = level or LevelCfg.new()
  self.activityCfg = activityCfg or MatchCfg.new()
  self.num = num or nil
end
function TeamInfo:marshal(os)
  os:marshalInt64(self.teamId)
  os:marshalInt64(self.leaderId)
  os:marshalString(self.teamLeaderName)
  os:marshalInt32(self.teamLeaderOccupation)
  os:marshalInt32(self.teamLeaderSex)
  os:marshalInt32(self.teamLeaderLevel)
  os:marshalInt32(self.avatarId)
  os:marshalInt32(self.avatarFrameId)
  os:marshalInt32(self.chatBubbleCfgId)
  self.level:marshal(os)
  self.activityCfg:marshal(os)
  os:marshalInt32(self.num)
end
function TeamInfo:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  self.leaderId = os:unmarshalInt64()
  self.teamLeaderName = os:unmarshalString()
  self.teamLeaderOccupation = os:unmarshalInt32()
  self.teamLeaderSex = os:unmarshalInt32()
  self.teamLeaderLevel = os:unmarshalInt32()
  self.avatarId = os:unmarshalInt32()
  self.avatarFrameId = os:unmarshalInt32()
  self.chatBubbleCfgId = os:unmarshalInt32()
  self.level = LevelCfg.new()
  self.level:unmarshal(os)
  self.activityCfg = MatchCfg.new()
  self.activityCfg:unmarshal(os)
  self.num = os:unmarshalInt32()
end
return TeamInfo
