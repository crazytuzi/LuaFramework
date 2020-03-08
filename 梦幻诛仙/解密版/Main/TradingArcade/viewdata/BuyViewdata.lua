local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BuyViewdata = Lplus.Class(MODULE_NAME)
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local def = BuyViewdata.define
local instance
def.static("=>", BuyViewdata).Instance = function()
  if instance == nil then
    instance = BuyViewdata()
  end
  return instance
end
def.method("=>", "table").GetAllTypes = function(self)
  local viewData = TradingArcadeUtils.GetMarketCfgs()
  return viewData
end
def.method("number", "=>", "boolean").IsSubIdAvailable = function(self, subId)
  local tradingArcadeModule = gmodule.moduleMgr:GetModule(ModuleId.TRADING_ARCADE)
  local cfgIds = tradingArcadeModule:FindGoodsCfgIdsBySubId(subId)
  if cfgIds == nil then
    return false
  end
  for i, itemId in ipairs(cfgIds.itemIds or {}) do
    if not tradingArcadeModule:IsItemForbidden(itemId) then
      return true
    end
  end
  for i, petCfgId in ipairs(cfgIds.petCfgIds or {}) do
    if not tradingArcadeModule:IsPetForbidden(petCfgId) then
      return true
    end
  end
  return false
end
def.method("table", "=>", "table").GetSubTypesViewdatas = function(self, subIdList)
  local heroLevel = require("Main.Hero.Interface").GetHeroProp().level
  local list = {}
  for i, subId in ipairs(subIdList) do
    local viewData = self:GetSubTypeViewdata(subId)
    if heroLevel >= viewData.needlevel and self:IsSubIdAvailable(subId) then
      list[#list + 1] = viewData
    end
  end
  table.sort(list, function(l, r)
    return l.sort < r.sort
  end)
  return list
end
def.method("number", "=>", "table").GetSubTypeViewdata = function(self, subId)
  local viewData = {isSubType = true, subId = subId}
  local cfg = TradingArcadeUtils.GetMarketSubTypeCfg(subId)
  if cfg == nil then
    viewData.name = "nil"
    viewData.icon = 0
    viewData.needlevel = 0
    return viewData
  end
  viewData.name = cfg.name
  viewData.icon = cfg.iconId
  viewData.ispricesort = cfg.ispricesort
  viewData.islevelsift = cfg.islevelsift
  viewData.needlevel = cfg.needlevel
  viewData.initLevel = cfg.initLevel
  viewData.levelDelta = cfg.levelDelta
  viewData.sort = cfg.sort
  viewData.isAsc = cfg.isAsc
  return viewData
end
return BuyViewdata.Commit()
