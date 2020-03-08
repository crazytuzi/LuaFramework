local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local BackToGameModule = Lplus.Extend(ModuleBase, "BackToGameModule")
require("Main.module.ModuleId")
local BTGDailySign = require("Main.BackToGame.mgr.BTGDailySign")
local BTGExp = require("Main.BackToGame.mgr.BTGExp")
local BTGBackHome = require("Main.BackToGame.mgr.BTGBackHome")
local BTGJiFen = require("Main.BackToGame.mgr.BTGJiFen")
local BTGLimitSell = require("Main.BackToGame.mgr.BTGLimitSell")
local BTGTask = require("Main.BackToGame.mgr.BTGTask")
local BTGCat = require("Main.BackToGame.mgr.BTGCat")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BackToGameModule.define
local instance
def.static("=>", BackToGameModule).Instance = function()
  if instance == nil then
    instance = BackToGameModule()
    instance.m_moduleId = ModuleId.BACK_TO_GAME
  end
  return instance
end
def.field("userdata").m_joinTime = nil
def.field("number").m_activityId = 0
def.field("number").m_joinLevel = 0
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.backgameactivity.SSynBackGameActivityInfo", BackToGameModule.OnSSynBackGameActivityInfo)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, BackToGameModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, BackToGameModule.OnNewDay)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BackToGameModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, BackToGameModule.OnMainUIShow)
  BTGDailySign.Instance():Init()
  BTGExp.Instance():Init()
  BTGBackHome.Instance():Init()
  BTGJiFen.Instance():Init()
  BTGLimitSell.Instance():Init()
  BTGTask.Instance():Init()
  BTGCat.Instance():Init()
  ModuleBase.Init(self)
end
def.static("table").OnSSynBackGameActivityInfo = function(p)
  local self = BackToGameModule.Instance()
  local cfg = BackToGameUtils.GetBackGameActivity(p.activity_id)
  if cfg then
    self.m_activityId = p.activity_id
    self.m_joinTime = p.join_time
    self.m_joinLevel = p.join_level
    local signTypeId = BackToGameUtils.GetDailySignCfgByLevel(cfg.signCfgId, self.m_joinLevel)
    local expTypeId = BackToGameUtils.GetExpTypeIdByLevel(cfg.expCfgId, self.m_joinLevel)
    BTGDailySign.Instance():SetData(p.sign_info, signTypeId)
    BTGJiFen.Instance():SetData(cfg.pointCfgId)
    BTGExp.Instance():SetData(p.exp_award_info, expTypeId)
    BTGTask.Instance():SetData(p.task_info, cfg.taskCfgId)
    BTGBackHome.Instance():SetData(p.award_info)
    BTGLimitSell.Instance():SetData(p.gift_info, cfg.giftCfgId)
    BTGCat.Instance():SetData(p.rechargeInfo, cfg.rechargeCfgId)
    local serverDay = BackToGameUtils.MsToDay(p.current_time)
    local curDay = BackToGameUtils.SecToDay(GetServerTime())
    if serverDay < curDay then
      BackToGameModule.OnNewDay(nil, nil)
    end
  end
end
def.method().Clear = function(self)
  BTGDailySign.Instance():Clear()
  BTGExp.Instance():Clear()
  BTGBackHome.Instance():Clear()
  BTGJiFen.Instance():Clear()
  BTGLimitSell.Instance():Clear()
  BTGTask.Instance():Clear()
  BTGCat.Instance():Clear()
  local self = BackToGameModule.Instance()
  self.m_joinTime = nil
  self.m_activityId = 0
  self.m_joinLevel = 0
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  local self = BackToGameModule.Instance()
  self:Clear()
end
def.static("table", "table").OnNewDay = function(p1, p2)
  local self = BackToGameModule.Instance()
  if not self:IsBackGamePlayer() then
    return
  end
  local startDay = BackToGameUtils.MsToDay(self.m_joinTime)
  local curDay = BackToGameUtils.SecToDay(GetServerTime())
  local cfg = BackToGameUtils.GetBackGameActivity(self.m_activityId)
  if curDay - startDay >= cfg.backGameCycleDay then
    self:HideBackToGame()
    self:Clear()
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  else
    BTGDailySign.Instance():NewDay()
    BTGExp.Instance():NewDay()
    BTGBackHome.Instance():NewDay()
    BTGJiFen.Instance():NewDay()
    BTGLimitSell.Instance():NewDay()
    BTGTask.Instance():NewDay()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local f = p1.feature
  if f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY then
    local self = BackToGameModule.Instance()
    self:HideBackToGame()
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  elseif f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_SIGN or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_POINT or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_EXP or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_AWARD or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_BUY_GIFT then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MENU_TOP_FLOAT_CHANGE, nil)
  end
end
def.static("table", "table").OnMainUIShow = function(p1, p2)
  GameUtil.AddGlobalTimer(2, true, function()
    local self = BackToGameModule.Instance()
    if self:IsBackGamePlayer() and BTGBackHome.Instance():GetCanDraw() then
      require("Main.BackToGame.ui.BackToGamePanel").ShowBackToGamePanel(4)
    end
  end)
end
def.method("=>", "userdata").GetJoinTime = function(self)
  return self.m_joinTime
end
def.method("=>", "number").GetCurActivity = function(self)
  return self.m_activityId
end
def.method("=>", "boolean").IsBackGamePlayer = function(self)
  local open = IsFeatureOpen(ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY)
  if open then
    return self.m_joinTime ~= nil and self.m_activityId > 0
  else
    return false
  end
end
def.method().ShowBackToGame = function(self)
  require("Main.BackToGame.ui.BackToGamePanel").ShowBackToGamePanel(0)
end
def.method().HideBackToGame = function(self)
  require("Main.BackToGame.ui.BackToGamePanel").HideBackToGamePanel()
end
def.method("=>", "boolean").IsRed = function(self)
  if self:IsBackGamePlayer() then
    if BTGDailySign.Instance():IsRed() or BTGExp.Instance():IsRed() or BTGBackHome.Instance():IsRed() or BTGJiFen.Instance():IsRed() or BTGLimitSell.Instance():IsRed() or BTGTask.Instance():IsRed() then
      return true
    else
      return false
    end
  else
    return false
  end
end
BackToGameModule.Commit()
return BackToGameModule
