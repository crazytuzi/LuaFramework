local OctetsStream = require("netio.OctetsStream")
local RoundRobinFightInfo = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
local RoundRobinFightBetInfo = class("RoundRobinFightBetInfo")
function RoundRobinFightBetInfo:ctor(fight_info, corps_a_bet_money_sum, corps_b_bet_money_sum, bet_corps_id, role_bet_money_num)
  self.fight_info = fight_info or RoundRobinFightInfo.new()
  self.corps_a_bet_money_sum = corps_a_bet_money_sum or nil
  self.corps_b_bet_money_sum = corps_b_bet_money_sum or nil
  self.bet_corps_id = bet_corps_id or nil
  self.role_bet_money_num = role_bet_money_num or nil
end
function RoundRobinFightBetInfo:marshal(os)
  self.fight_info:marshal(os)
  os:marshalInt64(self.corps_a_bet_money_sum)
  os:marshalInt64(self.corps_b_bet_money_sum)
  os:marshalInt64(self.bet_corps_id)
  os:marshalInt32(self.role_bet_money_num)
end
function RoundRobinFightBetInfo:unmarshal(os)
  self.fight_info = RoundRobinFightInfo.new()
  self.fight_info:unmarshal(os)
  self.corps_a_bet_money_sum = os:unmarshalInt64()
  self.corps_b_bet_money_sum = os:unmarshalInt64()
  self.bet_corps_id = os:unmarshalInt64()
  self.role_bet_money_num = os:unmarshalInt32()
end
return RoundRobinFightBetInfo
