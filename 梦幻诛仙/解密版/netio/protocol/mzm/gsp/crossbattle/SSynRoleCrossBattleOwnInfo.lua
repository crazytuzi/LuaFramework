local SSynRoleCrossBattleOwnInfo = class("SSynRoleCrossBattleOwnInfo")
SSynRoleCrossBattleOwnInfo.TYPEID = 12616988
function SSynRoleCrossBattleOwnInfo:ctor(activity_cfg_id, stage, vote_stage_direct_promotion_corps_list, round_robin_point_rank_list, round_robin_round_index, round_robin_round_stage, round_robin_stage_promotion_corps_list, register_info, vote_times, canvass_timestamp)
  self.id = 12616988
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
  self.vote_stage_direct_promotion_corps_list = vote_stage_direct_promotion_corps_list or {}
  self.round_robin_point_rank_list = round_robin_point_rank_list or {}
  self.round_robin_round_index = round_robin_round_index or nil
  self.round_robin_round_stage = round_robin_round_stage or nil
  self.round_robin_stage_promotion_corps_list = round_robin_stage_promotion_corps_list or {}
  self.register_info = register_info or nil
  self.vote_times = vote_times or nil
  self.canvass_timestamp = canvass_timestamp or nil
end
function SSynRoleCrossBattleOwnInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
  os:marshalCompactUInt32(table.getn(self.vote_stage_direct_promotion_corps_list))
  for _, v in ipairs(self.vote_stage_direct_promotion_corps_list) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.round_robin_point_rank_list))
  for _, v in ipairs(self.round_robin_point_rank_list) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.round_robin_round_index)
  os:marshalInt32(self.round_robin_round_stage)
  os:marshalCompactUInt32(table.getn(self.round_robin_stage_promotion_corps_list))
  for _, v in ipairs(self.round_robin_stage_promotion_corps_list) do
    os:marshalInt64(v)
  end
  os:marshalUInt8(self.register_info)
  os:marshalInt32(self.vote_times)
  os:marshalInt32(self.canvass_timestamp)
end
function SSynRoleCrossBattleOwnInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.vote_stage_direct_promotion_corps_list, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.round_robin_point_rank_list, v)
  end
  self.round_robin_round_index = os:unmarshalInt32()
  self.round_robin_round_stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.round_robin_stage_promotion_corps_list, v)
  end
  self.register_info = os:unmarshalUInt8()
  self.vote_times = os:unmarshalInt32()
  self.canvass_timestamp = os:unmarshalInt32()
end
function SSynRoleCrossBattleOwnInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleCrossBattleOwnInfo
