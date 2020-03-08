local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local LuckyStarModule = Lplus.Extend(ModuleBase, "LuckyStarModule")
local LuckyStarMgr = require("Main.LuckyStar.mgr.LuckyStarMgr")
local LuckyStarUIMgr = require("Main.LuckyStar.mgr.LuckyStarUIMgr")
local def = LuckyStarModule.define
local instance
def.static("=>", LuckyStarModule).Instance = function()
  if instance == nil then
    instance = LuckyStarModule()
    instance.m_moduleId = ModuleId.LUCKYSTAR
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckystar.SSyncLuckyStarInfo", LuckyStarModule.OnSSyncLuckyStarInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckystar.SBuyLuckyStarReqSuccess", LuckyStarModule.OnSBuyLuckyStarReqSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.luckystar.SLuckyStarNormalFail", LuckyStarModule.OnSLuckyStarNormalFail)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, LuckyStarModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, LuckyStarModule.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.OPEN_LUCKYSTAR_PANEL, LuckyStarModule.OnReceiveOpenLuckyStarReq)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, LuckyStarModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, LuckyStarModule.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, LuckyStarModule.OnActivityTodo)
  ModuleBase.Init(self)
end
def.static("table").OnSSyncLuckyStarInfo = function(p)
  LuckyStarMgr.Instance():SyncLuckyStarInfo(p)
  LuckyStarModule.Instance():CheckLuckyStarEntryVisible()
end
def.static("table").OnSBuyLuckyStarReqSuccess = function(p)
  LuckyStarMgr.Instance():SetLuckyStarBuyTimes(p.activity_cfg_id, p.lucky_star_gift_cfg_id, p.has_buy_times)
  Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.BUY_LUCKYSTAR_SUCCESS, {
    luckyStarCfgId = p.lucky_star_gift_cfg_id
  })
  Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_NOTIFY_CHANGE, nil)
  Toast(textRes.LuckyStar[8])
end
def.static("table").OnSLuckyStarNormalFail = function(p)
  if textRes.LuckyStar.SLuckStarNormalFail[p.result] ~= nil then
    Toast(textRes.LuckyStar.SLuckStarNormalFail[p.result])
  else
    Toast(textRes.LuckyStar[7])
  end
end
def.static("table", "table").OnReceiveOpenLuckyStarReq = function(params, context)
  LuckyStarModule.OpenLuckyStarPanel()
end
def.static("table", "table").OnLeaveWorld = function(params, context)
  LuckyStarMgr.Instance():ClearData()
end
def.static("table", "table").OnActivityEnd = function(params, context)
  local activityId = params[1]
  if activityId == LuckyStarMgr.Instance():GetLuckyStarActivityId() then
    LuckyStarMgr.Instance():ClearData()
    LuckyStarModule.Instance():CheckLuckyStarEntryVisible()
    Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, nil)
  end
end
def.static("table", "table").OnActivityTodo = function(params, context)
  local activityId = params[1]
  if activityId == LuckyStarMgr.Instance():GetLuckyStarActivityId() then
    LuckyStarModule.OpenLuckyStarPanel()
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUCKY_STAR then
    LuckyStarModule.Instance():CheckLuckyStarEntryVisible()
    Event.DispatchEvent(ModuleId.LUCKYSTAR, gmodule.notifyId.LuckyStar.LUCKYSTAR_STATUS_CHANGE, nil)
  end
end
def.static("table", "table").OnFunctionOpenInit = function(params, context)
  LuckyStarModule.Instance():CheckLuckyStarEntryVisible()
end
def.method().CheckLuckyStarEntryVisible = function(self)
  if not _G.IsEnteredWorld() then
    return
  end
  if LuckyStarUIMgr.Instance():IsShowLuckyStarEntry() then
    self:ShowLuckyStarEntry(true)
  else
    self:ShowLuckyStarEntry(false)
  end
end
def.method("boolean").ShowLuckyStarEntry = function(self, isShow)
  local LuckyStarEntry = require("Main.LuckyStar.ui.LuckyStarEntry")
  if isShow then
    LuckyStarEntry.Instance():ShowEntry()
  else
    LuckyStarEntry.Instance():HideEntry()
  end
end
def.method("=>", "boolean").IsLuckyStarOpened = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LUCKY_STAR) then
    return false
  end
  local activityId = LuckyStarMgr.Instance():GetLuckyStarActivityId()
  local isOpened = require("Main.activity.ActivityInterface").Instance():isActivityOpend(activityId)
  if not isOpened then
    return false
  end
  return true
end
def.static().OpenLuckyStarPanel = function()
  local result = LuckyStarModule.Instance():IsLuckyStarOpened()
  if result then
    require("Main.LuckyStar.ui.LuckyStarPanel").Instance():ShowPanel()
  else
    Toast(textRes.LuckyStar[9])
  end
end
return LuckyStarModule.Commit()
