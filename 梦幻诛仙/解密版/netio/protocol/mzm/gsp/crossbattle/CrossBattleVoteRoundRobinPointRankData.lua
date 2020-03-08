local OctetsStream = require("netio.OctetsStream")
local CorpsBriefInfo = require("netio.protocol.mzm.gsp.crossbattle.CorpsBriefInfo")
local CrossBattleVoteRoundRobinPointRankData = class("CrossBattleVoteRoundRobinPointRankData")
function CrossBattleVoteRoundRobinPointRankData:ctor(rank, corps_brief_info, point, win_num, lose_num, vote_num, vote_timestamp)
  self.rank = rank or nil
  self.corps_brief_info = corps_brief_info or CorpsBriefInfo.new()
  self.point = point or nil
  self.win_num = win_num or nil
  self.lose_num = lose_num or nil
  self.vote_num = vote_num or nil
  self.vote_timestamp = vote_timestamp or nil
end
function CrossBattleVoteRoundRobinPointRankData:marshal(os)
  os:marshalInt32(self.rank)
  self.corps_brief_info:marshal(os)
  os:marshalInt32(self.point)
  os:marshalInt32(self.win_num)
  os:marshalInt32(self.lose_num)
  os:marshalInt32(self.vote_num)
  os:marshalInt32(self.vote_timestamp)
end
function CrossBattleVoteRoundRobinPointRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.corps_brief_info = CorpsBriefInfo.new()
  self.corps_brief_info:unmarshal(os)
  self.point = os:unmarshalInt32()
  self.win_num = os:unmarshalInt32()
  self.lose_num = os:unmarshalInt32()
  self.vote_num = os:unmarshalInt32()
  self.vote_timestamp = os:unmarshalInt32()
end
return CrossBattleVoteRoundRobinPointRankData
