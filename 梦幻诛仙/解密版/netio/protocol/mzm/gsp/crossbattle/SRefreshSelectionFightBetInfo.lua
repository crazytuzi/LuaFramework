local SRefreshSelectionFightBetInfo = class("SRefreshSelectionFightBetInfo")
SRefreshSelectionFightBetInfo.TYPEID = 12617049
function SRefreshSelectionFightBetInfo:ctor(activity_cfg_id, fight_zone_id, selection_stage, fight_index, corps_a_bet_money_sum, corps_b_bet_money_sum)
  self.id = 12617049
  self.activity_cfg_id = activity_cfg_id or nil
  self.fight_zone_id = fight_zone_id or nil
  self.selection_stage = selection_stage or nil
  self.fight_index = fight_index or nil
  self.corps_a_bet_money_sum = corps_a_bet_money_sum or nil
  self.corps_b_bet_money_sum = corps_b_bet_money_sum or nil
end
function SRefreshSelectionFightBetInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.fight_zone_id)
  os:marshalInt32(self.selection_stage)
  os:marshalInt32(self.fight_index)
  os:marshalInt64(self.corps_a_bet_money_sum)
  os:marshalInt64(self.corps_b_bet_money_sum)
end
function SRefreshSelectionFightBetInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.fight_zone_id = os:unmarshalInt32()
  self.selection_stage = os:unmarshalInt32()
  self.fight_index = os:unmarshalInt32()
  self.corps_a_bet_money_sum = os:unmarshalInt64()
  self.corps_b_bet_money_sum = os:unmarshalInt64()
end
function SRefreshSelectionFightBetInfo:sizepolicy(size)
  return size <= 65535
end
return SRefreshSelectionFightBetInfo
