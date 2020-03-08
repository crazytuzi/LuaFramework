local OctetsStream = require("netio.OctetsStream")
local KnockoutFightBetInfo = class("KnockoutFightBetInfo")
function KnockoutFightBetInfo:ctor(corps_a_bet_money_sum, corps_b_bet_money_sum, role_bet_corps_id, role_bet_money_num)
  self.corps_a_bet_money_sum = corps_a_bet_money_sum or nil
  self.corps_b_bet_money_sum = corps_b_bet_money_sum or nil
  self.role_bet_corps_id = role_bet_corps_id or nil
  self.role_bet_money_num = role_bet_money_num or nil
end
function KnockoutFightBetInfo:marshal(os)
  os:marshalInt64(self.corps_a_bet_money_sum)
  os:marshalInt64(self.corps_b_bet_money_sum)
  os:marshalInt64(self.role_bet_corps_id)
  os:marshalInt32(self.role_bet_money_num)
end
function KnockoutFightBetInfo:unmarshal(os)
  self.corps_a_bet_money_sum = os:unmarshalInt64()
  self.corps_b_bet_money_sum = os:unmarshalInt64()
  self.role_bet_corps_id = os:unmarshalInt64()
  self.role_bet_money_num = os:unmarshalInt32()
end
return KnockoutFightBetInfo
