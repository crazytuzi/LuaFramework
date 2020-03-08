local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = require("netio.protocol.mzm.gsp.crossbattle.CorpsBriefInfo")
local CrossBattleVoteRankData = class("CrossBattleVoteRankData")
function CrossBattleVoteRankData:ctor(rank, corps_brief_info, vote_num, vote_timestamp, average_fight_value)
  self.rank = rank or nil
  self.corps_brief_info = corps_brief_info or CorpsBriefInfo.new()
  self.vote_num = vote_num or nil
  self.vote_timestamp = vote_timestamp or nil
  self.average_fight_value = average_fight_value or nil
end
function CrossBattleVoteRankData:marshal(os)
  os:marshalInt32(self.rank)
  self.corps_brief_info:marshal(os)
  os:marshalInt32(self.vote_num)
  os:marshalInt32(self.vote_timestamp)
  os:marshalFloat(self.average_fight_value)
end
function CrossBattleVoteRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.corps_brief_info = CorpsBriefInfo.new()
  self.corps_brief_info:unmarshal(os)
  self.vote_num = os:unmarshalInt32()
  self.vote_timestamp = os:unmarshalInt32()
  self.average_fight_value = os:unmarshalFloat()
end
return CrossBattleVoteRankData
