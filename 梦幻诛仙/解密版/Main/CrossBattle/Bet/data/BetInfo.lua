local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfo = Lplus.Class(MODULE_NAME)
local def = BetInfo.define
def.field("number").m_selfBetMoneyNum = -1
def.field("userdata").m_selfBetCorpsId = nil
def.field("userdata").m_moneyNumOnA = nil
def.field("userdata").m_moneyNumOnB = nil
def.field("table").m_fightInfo = nil
def.final("table", "=>", BetInfo).new = function(self, params)
  local obj = BetInfo()
  obj:ctor(params)
  return obj
end
def.virtual("table").ctor = function(self, params)
end
def.method("=>", "number").GetSelfBetMoneyNum = function(self)
  return self.m_selfBetMoneyNum
end
def.method("=>", "userdata").GetMoneyNumOnA = function(self)
  return self.m_moneyNumOnA
end
def.method("=>", "userdata").GetMoneyNumOnB = function(self)
  return self.m_moneyNumOnB
end
def.method("=>", "table").GetFightInfo = function(self)
  return self.m_fightInfo
end
def.method("=>", "userdata").GetSelfBetCorpsId = function(self)
  return self.m_selfBetCorpsId
end
def.method("userdata").SetSelfBetCorpsId = function(self, value)
  self.m_selfBetCorpsId = value
end
def.method("number").SetSelfBetMoneyNum = function(self, value)
  self.m_selfBetMoneyNum = value
end
def.method("number").AddSelfBetMoneyNum = function(self, value)
  if self.m_selfBetMoneyNum == -1 then
    self.m_selfBetMoneyNum = value
  else
    self.m_selfBetMoneyNum = self.m_selfBetMoneyNum + value
  end
end
def.method("userdata").SetMoneyNumOnA = function(self, value)
  self.m_moneyNumOnA = value
end
def.method("userdata").SetMoneyNumOnB = function(self, value)
  self.m_moneyNumOnB = value
end
def.method("table").SetFightInfo = function(self, value)
  self.m_fightInfo = value
end
return BetInfo.Commit()
