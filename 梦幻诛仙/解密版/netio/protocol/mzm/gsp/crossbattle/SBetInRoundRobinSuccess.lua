local SBetInRoundRobinSuccess = class("SBetInRoundRobinSuccess")
SBetInRoundRobinSuccess.TYPEID = 12617035
function SBetInRoundRobinSuccess:ctor(activity_cfg_id, round_index, target_corps_id, sortid, corps_a_bet_money_sum, corps_b_bet_money_sum)
  self.id = 12617035
  self.activity_cfg_id = activity_cfg_id or nil
  self.round_index = round_index or nil
  self.target_corps_id = target_corps_id or nil
  self.sortid = sortid or nil
  self.corps_a_bet_money_sum = corps_a_bet_money_sum or nil
  self.corps_b_bet_money_sum = corps_b_bet_money_sum or nil
end
function SBetInRoundRobinSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.round_index)
  os:marshalInt64(self.target_corps_id)
  os:marshalInt32(self.sortid)
  os:marshalInt64(self.corps_a_bet_money_sum)
  os:marshalInt64(self.corps_b_bet_money_sum)
end
function SBetInRoundRobinSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.round_index = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
  self.sortid = os:unmarshalInt32()
  self.corps_a_bet_money_sum = os:unmarshalInt64()
  self.corps_b_bet_money_sum = os:unmarshalInt64()
end
function SBetInRoundRobinSuccess:sizepolicy(size)
  return size <= 65535
end
return SBetInRoundRobinSuccess
