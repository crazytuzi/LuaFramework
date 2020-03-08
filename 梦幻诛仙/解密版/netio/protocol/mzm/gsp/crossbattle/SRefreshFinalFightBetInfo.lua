local SRefreshFinalFightBetInfo = class("SRefreshFinalFightBetInfo")
SRefreshFinalFightBetInfo.TYPEID = 12617073
function SRefreshFinalFightBetInfo:ctor(activity_cfg_id, stage, fight_index, corps_a_bet_money_sum, corps_b_bet_money_sum)
  self.id = 12617073
  self.activity_cfg_id = activity_cfg_id or nil
  self.stage = stage or nil
  self.fight_index = fight_index or nil
  self.corps_a_bet_money_sum = corps_a_bet_money_sum or nil
  self.corps_b_bet_money_sum = corps_b_bet_money_sum or nil
end
function SRefreshFinalFightBetInfo:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.fight_index)
  os:marshalInt64(self.corps_a_bet_money_sum)
  os:marshalInt64(self.corps_b_bet_money_sum)
end
function SRefreshFinalFightBetInfo:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.fight_index = os:unmarshalInt32()
  self.corps_a_bet_money_sum = os:unmarshalInt64()
  self.corps_b_bet_money_sum = os:unmarshalInt64()
end
function SRefreshFinalFightBetInfo:sizepolicy(size)
  return size <= 65535
end
return SRefreshFinalFightBetInfo
