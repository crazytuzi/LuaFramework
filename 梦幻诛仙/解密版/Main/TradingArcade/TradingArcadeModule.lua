local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local TradingArcadeModule = Lplus.Extend(ModuleBase, "TradingArcadeModule")
local TradingArcadeProtocol = require("Main.TradingArcade.TradingArcadeProtocol")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
local SellServiceMgr = require("Main.TradingArcade.SellServiceMgr")
local def = TradingArcadeModule.define
local instance
def.static("=>", TradingArcadeModule).Instance = function()
  if instance == nil then
    instance = TradingArcadeModule()
    instance.m_moduleId = ModuleId.TRADING_ARCADE
  end
  return instance
end
def.const("table").BanState = {Banned = 0, None = 1}
def.field("table").m_subId2cfgIds = nil
def.field("table").m_itemBanStates = nil
def.field("table").m_petBanStates = nil
def.override().Init = function(self)
  ModuleBase.Init(self)
  TradingArcadeProtocol.Init()
  BuyServiceMgr.Instance():Init()
  SellServiceMgr.Instance():Init()
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.SHOW_GOODS_DETIAL_INFO, TradingArcadeModule.OnReqShowGoodsDetial)
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.FOCUS_ON_GOODS, TradingArcadeModule.OnReqFocusOnGoods)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, TradingArcadeModule.OnLeaveWorld)
end
def.method("=>", "boolean").HasNotify = function(self)
  if SellServiceMgr.Instance():HasNotify() then
    return true
  end
  if require("Main.TradingArcade.CustomizedSearchMgr").Instance():HasNotify() then
    return true
  end
  if require("Main.TradingArcade.BidMgr").Instance():HasNotify() then
    return true
  end
  return false
end
def.method("number", "=>", "boolean").IsGoodsForbidden = function(self, cfgId)
  if TradingArcadeUtils.IsItemSubType(cfgId) then
    return self:IsItemForbidden(cfgId)
  elseif TradingArcadeUtils.IsPetSubType(cfgId) then
    return self:IsPetForbidden(cfgId)
  end
  return true
end
def.method("number", "=>", "boolean").IsItemForbidden = function(self, itemId)
  if self.m_itemBanStates == nil then
    return false
  end
  return self.m_itemBanStates[itemId] == TradingArcadeModule.BanState.Banned
end
def.method("number", "=>", "boolean").IsPetForbidden = function(self, petCfgId)
  if self.m_petBanStates == nil then
    return false
  end
  return self.m_petBanStates[petCfgId] == TradingArcadeModule.BanState.Banned
end
def.method("number", "=>", "table").FindGoodsCfgIdsBySubId = function(self, subId)
  if self.m_subId2cfgIds == nil then
    self.m_subId2cfgIds = {}
    local marketItemCfgs = TradingArcadeUtils.GetAllMarketItemCfgs()
    for i, v in ipairs(marketItemCfgs) do
      self.m_subId2cfgIds[v.subid] = self.m_subId2cfgIds[v.subid] or {}
      self.m_subId2cfgIds[v.subid].itemIds = self.m_subId2cfgIds[v.subid].itemIds or {}
      table.insert(self.m_subId2cfgIds[v.subid].itemIds, v.itemid)
    end
    local marketPetCfgs = TradingArcadeUtils.GetAllMarketPetCfgs()
    for i, v in ipairs(marketPetCfgs) do
      self.m_subId2cfgIds[v.subid] = self.m_subId2cfgIds[v.subid] or {}
      self.m_subId2cfgIds[v.subid].petCfgIds = self.m_subId2cfgIds[v.subid].petCfgIds or {}
      table.insert(self.m_subId2cfgIds[v.subid].petCfgIds, v.petid)
    end
  end
  return self.m_subId2cfgIds[subId]
end
def.method("number", "number").SetItemBanState = function(self, itemId, state)
  self.m_itemBanStates = self.m_itemBanStates or {}
  self.m_itemBanStates[itemId] = state
end
def.method("number", "number").SetPetBanState = function(self, petCfgId, state)
  self.m_petBanStates = self.m_petBanStates or {}
  self.m_petBanStates[petCfgId] = state
end
def.method().Clear = function(self)
  self.m_itemBanStates = nil
  self.m_petBanStates = nil
  self:ClearSubId2CfgIdCaches()
end
def.method().ClearSubId2CfgIdCaches = function(self)
  self.m_subId2cfgIds = nil
end
def.static("table", "table").OnReqShowGoodsDetial = function(params)
  if TradingArcadeUtils.CheckOpen() == false then
    return
  end
  local marketId = Int64.ParseString(params[1])
  local refId = tonumber(params[2])
  local price = tonumber(params[3])
  local PetUtility = require("Main.Pet.PetUtility")
  if PetUtility.IsPetCfgId(refId) then
    TradingArcadeProtocol.CQueryPetInfoReq(marketId, refId, price, function(p)
      local PetInfoPanel = require("Main.Pet.ui.PetInfoPanel")
      PetInfoPanel.Instance():ShowPanelByPetInfo(p.petInfo)
    end)
  else
    TradingArcadeProtocol.CQueryItemInfoReq(marketId, refId, price, function(p)
      local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
      ItemTipsMgr.Instance():ShowTips(p.itemInfo, 0, 0, ItemTipsMgr.Source.ChatOther, 0, 0, 0, 0, 0)
    end)
  end
end
def.static("table", "table").OnReqFocusOnGoods = function(params)
  if TradingArcadeUtils.CheckOpen() == false then
    return
  end
  local marketId = Int64.ParseString(params[1])
  local refId = tonumber(params[2])
  local price = tonumber(params[3])
  warn("OnReqFocusOnGoods", tostring(marketId), refId)
  local PetUtility = require("Main.Pet.PetUtility")
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  if PetUtility.IsPetCfgId(refId) then
    TradingArcadeProtocol.CQueryPetInfoReq(marketId, refId, price, function(p)
      local params = {
        marketPet = p.marketPet
      }
      CommercePitchModule.TradingArcadeBuy(params)
    end)
  else
    TradingArcadeProtocol.CQueryItemInfoReq(marketId, refId, price, function(p)
      local params = {
        marketItem = p.marketItem
      }
      CommercePitchModule.TradingArcadeBuy(params)
    end)
  end
end
def.static("table", "table").OnLeaveWorld = function()
  instance:Clear()
end
return TradingArcadeModule.Commit()
