local CrossBattleVoteRankData = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRankData")
local SGetCrossBattleVoteRankSuccess = class("SGetCrossBattleVoteRankSuccess")
SGetCrossBattleVoteRankSuccess.TYPEID = 12616974
function SGetCrossBattleVoteRankSuccess:ctor(activity_cfg_id, rank_type, myrank, rankList)
  self.id = 12616974
  self.activity_cfg_id = activity_cfg_id or nil
  self.rank_type = rank_type or nil
  self.myrank = myrank or CrossBattleVoteRankData.new()
  self.rankList = rankList or {}
end
function SGetCrossBattleVoteRankSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.rank_type)
  self.myrank:marshal(os)
  os:marshalCompactUInt32(table.getn(self.rankList))
  for _, v in ipairs(self.rankList) do
    v:marshal(os)
  end
end
function SGetCrossBattleVoteRankSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.rank_type = os:unmarshalInt32()
  self.myrank = CrossBattleVoteRankData.new()
  self.myrank:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.rankList, v)
  end
end
function SGetCrossBattleVoteRankSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetCrossBattleVoteRankSuccess
