local MODULE_NAME = (...)
local Lplus = require("Lplus")
local CustomizedSearch = Lplus.Class(MODULE_NAME)
local MathHelper = require("Common.MathHelper")
local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local ConditionState = require("netio.protocol.mzm.gsp.market.ConditionState")
local def = CustomizedSearch.define
def.const("table").CustomizeType = {
  Equip = 1,
  PetEquip = 2,
  Pet = 3
}
def.const("table").PeriodState = ConditionState
def.field("number").vindex = 0
def.field("table").condition = nil
def.field("number").periodState = ConditionState.NONE
def.field("number").type = 0
def.virtual().Init = function(self)
end
def.method("=>", "number").GetPeriodState = function(self)
  return self.periodState
end
def.method("=>", "string").GetPeriodStateName = function(self)
  local name = textRes.TradingArcade.PeriodStateName[self.periodState] or ""
  if self.periodState == ConditionState.IN_SELL then
    name = string.format("[ea01fd]%s[-]", name)
  elseif self.periodState == ConditionState.IN_PUBLIC then
    name = string.format("[009fd6]%s[-]", name)
  end
  return name
end
def.method().ResetPeriodState = function(self)
  self.periodState = CustomizedSearch.PeriodState.NONE
  Event.DispatchEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, {hasNotify})
end
def.method("=>", "boolean").HasNotify = function(self)
  if self.periodState ~= CustomizedSearch.PeriodState.NONE then
    return true
  end
  return false
end
def.virtual("=>", "string").GetDisplayName = function(self)
  return ""
end
def.virtual("=>", "string").GetConditionDesc = function(self)
  return ""
end
def.virtual().Search = function(self)
  local params = {}
  local state = self.periodState
  if state == CustomizedSearch.PeriodState.NONE then
    state = CustomizedSearch.PeriodState.IN_SELL
  end
  params.periodState = state
  local searchDelegate = self:GetSearchMgrDelegate()
  SearchMgr.Instance():InvokeSearch(searchDelegate, self.condition, params)
end
def.virtual("=>", "table").GetSearchMgrDelegate = function(self)
  return nil
end
def.virtual("table", "=>", "boolean").IsConditionEqual = function(self, condition)
  return false
end
return CustomizedSearch.Commit()
