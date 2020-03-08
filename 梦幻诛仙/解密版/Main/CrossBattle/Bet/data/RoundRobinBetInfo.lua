local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BetInfo = import(".BetInfo")
local RoundRobinBetInfo = Lplus.Extend(BetInfo, MODULE_NAME)
local def = RoundRobinBetInfo.define
def.field("number").m_roundIndex = 0
def.final("table", "=>", RoundRobinBetInfo).new = function(self, params)
  local obj = RoundRobinBetInfo()
  obj:ctor(params)
  return obj
end
def.method("=>", "number").GetRoundIndex = function(self)
  return self.m_roundIndex
end
def.method("number").SetRoundIndex = function(self, value)
  self.m_roundIndex = value
end
return RoundRobinBetInfo.Commit()
