local SSynVoteStageResultInCrossBattle = class("SSynVoteStageResultInCrossBattle")
SSynVoteStageResultInCrossBattle.TYPEID = 12616985
function SSynVoteStageResultInCrossBattle:ctor(activity_cfg_id, vote_stage_direct_promotion_corps_list, round_robin_point_rank_list)
  self.id = 12616985
  self.activity_cfg_id = activity_cfg_id or nil
  self.vote_stage_direct_promotion_corps_list = vote_stage_direct_promotion_corps_list or {}
  self.round_robin_point_rank_list = round_robin_point_rank_list or {}
end
function SSynVoteStageResultInCrossBattle:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.vote_stage_direct_promotion_corps_list))
  for _, v in ipairs(self.vote_stage_direct_promotion_corps_list) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.round_robin_point_rank_list))
  for _, v in ipairs(self.round_robin_point_rank_list) do
    v:marshal(os)
  end
end
function SSynVoteStageResultInCrossBattle:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.vote_stage_direct_promotion_corps_list, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.CrossBattleVoteRankData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.round_robin_point_rank_list, v)
  end
end
function SSynVoteStageResultInCrossBattle:sizepolicy(size)
  return size <= 65535
end
return SSynVoteStageResultInCrossBattle
