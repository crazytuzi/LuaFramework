local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local CustomActivityModule = Lplus.Extend(ModuleBase, "CustomActivityModule")
local CustomActivityInterface = require("Main.CustomActivity.CustomActivityInterface")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ItemModule = require("Main.Item.ItemModule")
local customActivityInterface = CustomActivityInterface.Instance()
local def = CustomActivityModule.define
local instance
def.static("=>", CustomActivityModule).Instance = function()
  if instance == nil then
    instance = CustomActivityModule()
    instance.m_moduleId = ModuleId.CUSTOM_ACTIVITY
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncSaveAmtActivityInfo", CustomActivityModule.OnSSyncSaveAmtActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardSuccess", CustomActivityModule.OnSGetSaveAmtActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetSaveAmtActivityAwardFailed", CustomActivityModule.OnSGetSaveAmtActivityAwardFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncAccumTotalCostActivityInfo", CustomActivityModule.OnSSyncAccumTotalCostActivityInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetAccumTotalCostActivityAwardSuccess", CustomActivityModule.OnSGetAccumTotalCostActivityAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SGetAccumTotalCostActivityAwardFailed", CustomActivityModule.OnSGetAccumTotalCostActivityAwardFailed)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CUSTOM_ACTIVITY, CustomActivityModule.onCustomActivityClick)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, CustomActivityModule.OnBuyYuanBaoChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, CustomActivityModule.OnAwardYuanBaoChanged)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CustomActivityModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, CustomActivityModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, CustomActivityModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, CustomActivityModule.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, CustomActivityModule.OnActivityEnd)
  require("Main.CustomActivity.GiftActivityMgr").Instance():Init()
  require("Main.CustomActivity.TimedLoginMgr").Instance():Init()
  require("Main.CustomActivity.LimitTimeSignInMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
end
def.static("table", "table").onCustomActivityClick = function(p1, p2)
  local CustomActivityPanel = require("Main.CustomActivity.ui.CustomActivityPanel")
  CustomActivityPanel.Instance():ShowPanel()
end
def.static("table", "table").OnBuyYuanBaoChanged = function(p1, p2)
  customActivityInterface:calcLimitChargeRedPoint()
  customActivityInterface:calcAccumCostRedPoint()
end
def.static("table", "table").OnAwardYuanBaoChanged = function(p1, p2)
  customActivityInterface:calcAccumCostRedPoint()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1.feature == Feature.TYPE_QING_FU_TIME_LIMITED_SAVE_AMT then
    customActivityInterface:calcLimitChargeRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  elseif p1.feature == Feature.TYPE_QING_FU_TIME_LIMITED_ACCUM_TOTAL_COST then
    customActivityInterface:calcAccumCostRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  elseif p1.feature == Feature.TYPE_TIME_LIMIT_GIFT then
    customActivityInterface:calcTimeLimitedGiftRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  elseif p1.feature == Feature.TYPE_LOGIN_ACTIVITY or p1.feature == Feature.TYPE_LOGIN_SUM_ACTIVITY then
    customActivityInterface:calcTimedLoginRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  elseif p1.feature == Feature.TYPE_LOGIN_SIGN_ACTIVITY then
    local req = require("netio.protocol.mzm.gsp.loginaward.CGetLoginSignActivityInfo").new()
    gmodule.network.sendProtocol(req)
    customActivityInterface:calcLimitTimeSignInRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  end
end
def.static("table", "table").OnActivityStart = function(p1, p2)
  local activityId = p1[1]
  customActivityInterface:setLimitChargeActivityId()
  customActivityInterface:setLimitCostActivityId()
  if activityId == CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID then
    local curYuanbao = ItemModule.Instance():GetYuanbao(ItemModule.CASH_SAVE_AMT)
    customActivityInterface:setLimitChargeInfo({base_save_amt = curYuanbao, sortid = 0})
    customActivityInterface:calcLimitChargeRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  elseif activityId == CustomActivityInterface.LIMIT_COST_ACTIVITY_ID then
    local totalCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST):tostring())
    local bindCost = tonumber(ItemModule.Instance():GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND):tostring())
    customActivityInterface:setAccumTotalCostInfos({
      [CustomActivityInterface.LIMIT_COST_ACTIVITY_ID] = {
        base_accum_total_cost = Int64.new(totalCost + bindCost),
        sortid = 0
      }
    })
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  end
end
def.static("table", "table").OnActivityEnd = function(p1, p2)
  local activityId = p1[1]
  customActivityInterface:setLimitChargeActivityId()
  customActivityInterface:setLimitCostActivityId()
  if activityId == CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID then
    customActivityInterface:calcLimitChargeRedPoint()
  elseif activityId == CustomActivityInterface.LIMIT_COST_ACTIVITY_ID then
    customActivityInterface:calcAccumCostRedPoint()
  end
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
end
def.static("table").OnSSyncSaveAmtActivityInfo = function(p)
  customActivityInterface:setLimitChargeActivityId()
  local limitChargeId = CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID
  if p.activity_infos[limitChargeId] then
    customActivityInterface:setLimitChargeInfo(p.activity_infos[limitChargeId])
    customActivityInterface:calcLimitChargeRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
  end
end
def.static("table").OnSGetSaveAmtActivityAwardSuccess = function(p)
  if p.activity_id == CustomActivityInterface.LIMIT_CHARGE_ACTIVITY_ID then
    customActivityInterface:changeLimtChargeSortid(p.sort_id)
    customActivityInterface:calcLimitChargeRedPoint()
    Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_CHARGE_INFO_CHANGE, {
      p.sort_id
    })
  end
end
def.static("table").OnSGetSaveAmtActivityAwardFailed = function(p)
  warn("-----CustomActivity----OnSGetSaveAmtActivityAwardFailed:", p.retcode)
end
def.static("table").OnSSyncAccumTotalCostActivityInfo = function(p)
  customActivityInterface:setLimitCostActivityId()
  customActivityInterface:setAccumTotalCostInfos(p.activity_infos)
  customActivityInterface:calcAccumCostRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, {})
end
def.static("table").OnSGetAccumTotalCostActivityAwardSuccess = function(p)
  customActivityInterface:changeAccumCostInfo(p.activity_cfgid, p.sort_id)
  customActivityInterface:calcAccumCostRedPoint()
  Event.DispatchEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.LIMIT_ACCUM_COST_CHANGE, {
    p.activity_cfgid,
    p.sort_id
  })
end
def.static("table").OnSGetAccumTotalCostActivityAwardFailed = function(p)
  warn("----OnSGetAccumTotalCostActivityAwardFailed:", p.retcode, p.activity_cfgid, p.sortid)
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  customActivityInterface:calcLimitChargeRedPoint()
  customActivityInterface:calcAccumCostRedPoint()
  customActivityInterface:calcTimeLimitedGiftRedPoint()
  customActivityInterface:calcTimedLoginRedPoint()
  customActivityInterface:calcLimitTimeSignInRedPoint()
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  customActivityInterface:calcLimitTimeSignInRedPoint()
end
return CustomActivityModule.Commit()
