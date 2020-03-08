local MODULE_NAME = (...)
local Lplus = require("Lplus")
local KnockOutBetInfo = import(".KnockOutBetInfo")
local SelectionBetInfo = Lplus.Extend(KnockOutBetInfo, MODULE_NAME)
local def = SelectionBetInfo.define
def.field("number").m_fightZoneId = 0
def.final("table", "=>", SelectionBetInfo).new = function(self, params)
  local obj = SelectionBetInfo()
  obj:ctor(params)
  return obj
end
def.method("=>", "number").GetFightZoneId = function(self)
  return self.m_fightZoneId
end
def.method("number").SetFightZoneId = function(self, value)
  self.m_fightZoneId = value
end
return SelectionBetInfo.Commit()
