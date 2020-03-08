local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfo = import(".BetInfo")
local KnockOutBetInfo = Lplus.Extend(BetInfo, MODULE_NAME)
local def = KnockOutBetInfo.define
def.field("number").m_stage = 0
def.field("number").m_fightIndex = 0
def.final("table", "=>", KnockOutBetInfo).new = function(self, params)
  local obj = KnockOutBetInfo()
  obj:ctor(params)
  return obj
end
def.method("=>", "number").GetStage = function(self)
  return self.m_stage
end
def.method("=>", "number").GetFightIndex = function(self)
  return self.m_fightIndex
end
def.method("number").SetFightIndex = function(self, value)
  self.m_fightIndex = value
end
def.method("number").SetStage = function(self, value)
  self.m_stage = value
end
def.method("table").SetFromBean_KnockoutFightBetInfo = function(self, bean)
  self:SetSelfBetCorpsId(bean.role_bet_corps_id)
  self:SetSelfBetMoneyNum(bean.role_bet_money_num)
  self:SetMoneyNumOnA(bean.corps_a_bet_money_sum)
  self:SetMoneyNumOnB(bean.corps_b_bet_money_sum)
end
return KnockOutBetInfo.Commit()
