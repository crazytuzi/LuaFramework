local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUITopActivity = Lplus.Extend(ComponentBase, "MainUITopActivity")
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local DailyGoalMgr = require("Main.Grow.DailyGoalMgr")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = MainUITopActivity.define
def.field("boolean").isOpened = false
def.field("boolean").isNewActivity = false
def.field("boolean").isNewActiveValue = false
def.field("boolean")._isShowGuideFrame = false
def.field("boolean").isOwnActivityEffect = false
local instance
def.static("=>", MainUITopActivity).Instance = function()
  if instance == nil then
    instance = MainUITopActivity()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, MainUITopActivity.OnActivityListChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MainUITopActivity.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, MainUITopActivity.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, MainUITopActivity.OnActivityClearNewFlag)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ImportantActivityChanged, MainUITopActivity.OnImportantActivity)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, MainUITopActivity.OnActiveAwardChged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, MainUITopActivity.OnActiveAwardChged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, MainUITopActivity.OnRefreshActivityRedPoint)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_SHOW, MainUITopActivity.OnTaskCutShow)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_HIDE, MainUITopActivity.OnTaskCutHide)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, MainUITopActivity.OnDailyGoalNotifyUpdate)
  local Btn_Activity = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity")
  local Label_New = Btn_Activity:FindDirect("Label_New")
  Label_New:SetActive(false)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, MainUITopActivity.OnActivityListChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MainUITopActivity.OnActivityStart)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, MainUITopActivity.OnActivityEnd)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, MainUITopActivity.OnActivityClearNewFlag)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ImportantActivityChanged, MainUITopActivity.OnImportantActivity)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, MainUITopActivity.OnActiveAwardChged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, MainUITopActivity.OnActiveAwardChged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, MainUITopActivity.OnRefreshActivityRedPoint)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_SHOW, MainUITopActivity.OnTaskCutShow)
  Event.UnregisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_CUT_HIDE, MainUITopActivity.OnTaskCutHide)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, MainUITopActivity.OnDailyGoalNotifyUpdate)
end
def.override().OnShow = function(self)
  self:UpdateUI()
end
def.override().OnHide = function(self)
end
def.method().UpdateUI = function(self)
  self:_Refresh()
  self:_RefreshActiveValue()
  self:_RefreshFrameShowHide()
end
def.override("string").OnClick = function(self, id)
end
def.method()._Refresh = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local Btn_Activity = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity")
  local Img_ActivityRed = Btn_Activity:FindDirect("Img_ActivityRed")
  local Label_ActivityRedNum = Img_ActivityRed:FindDirect("Label_ActivityRedNum")
  local hasNew = #activityInterface._newLevelOpenActivitiesVector > 0 or 0 < #activityInterface._newTimeOpenActivitiesVector or 0 < #activityInterface._newFestivalActivitiesVector
  local hasImportant = 0 < #activityInterface._importantActivitiesVector
  local isOwnRedPoint = false
  for i, v in pairs(activityInterface.activityRedPoint) do
    if v then
      isOwnRedPoint = v
      break
    end
  end
  local red = hasNew == true or hasImportant == true or isOwnRedPoint
  self.isNewActivity = red
  Img_ActivityRed:SetActive(false)
  Label_ActivityRedNum:SetActive(false)
  if red then
    if not self.isOwnActivityEffect then
      GUIUtils.SetLightEffect(Btn_Activity, GUIUtils.Light.Round)
      self.isOwnActivityEffect = true
    end
  else
    GUIUtils.SetLightEffect(Btn_Activity, GUIUtils.Light.None)
    self.isOwnActivityEffect = false
  end
  self:UpdateRedImgState()
end
def.method()._RefreshActiveValue = function(self)
  self.isNewActiveValue = false
  local awardCfg = ActivityInterface.GetActiveAwardCfg()
  if awardCfg == nil then
    warn("-------mainUITopActivity Award------nil")
    return
  end
  for i = 1, 6 do
    local cfg = awardCfg[i]
    if cfg and activityInterface._currentTotalActive >= cfg.activiteValue then
      local awared = activityInterface:GetActiveAwared(cfg.awardIndex)
      if awared == false then
        self.isNewActiveValue = true
        break
      end
    end
  end
  self:UpdateRedImgState()
end
def.method().UpdateRedImgState = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local Img_Red = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity/Img_Red")
  local hasNotify = self.isNewActivity or self.isNewActiveValue
  hasNotify = hasNotify or DailyGoalMgr.Instance():HasNotify()
  Img_Red:SetActive(hasNotify)
  gmodule.moduleMgr:GetModule(ModuleId.MAINUI):SetTopLeftBtnsNotifyCount(Img_Red.parent, hasNotify and 1 or 0)
end
def.method()._RefreshFrameShowHide = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local Img_Frame = self.m_panel:FindDirect("Pnl_BtnGroup_Top/BtnGroup_Top/Btn_Activity/Img_Frame")
  Img_Frame:SetActive(self._isShowGuideFrame)
end
def.method("=>", "boolean").IsOpen = function(self)
  local dailyList = activityInterface:GetDailyActivityList()
  if #dailyList > 0 then
    return true
  else
    return false
  end
end
def.method().Reset = function(self)
  self.isOpened = false
  self.isNewActivity = false
  self.isNewActiveValue = false
  self.isOwnActivityEffect = false
end
def.static("table", "table").OnActivityListChanged = function()
  local self = instance
  self:_Refresh()
end
def.static("table", "table").OnActivityStart = function(activityIDs, p2)
  local self = instance
  self:_Refresh()
end
def.static("table", "table").OnActivityEnd = function(activityIDs, p2)
  local self = instance
  self:_Refresh()
end
def.static("table", "table").OnActivityClearNewFlag = function()
  local self = instance
  self:_Refresh()
  self._isShowGuideFrame = false
  self:_RefreshFrameShowHide()
end
def.static("table", "table").OnImportantActivity = function()
  local self = instance
  self:_Refresh()
end
def.static("table", "table").OnActiveAwardChged = function()
  local self = instance
  self:_RefreshActiveValue()
end
def.static("table", "table").OnTaskCutShow = function()
  local self = instance
  self._isShowGuideFrame = true
  self:_RefreshFrameShowHide()
end
def.static("table", "table").OnTaskCutHide = function()
  local self = instance
  self._isShowGuideFrame = false
  self:_RefreshFrameShowHide()
end
def.static("table", "table").OnRefreshActivityRedPoint = function(p1, p2)
  local self = instance
  self:_Refresh()
end
def.static("table", "table").OnDailyGoalNotifyUpdate = function()
  local self = instance
  self:UpdateRedImgState()
end
MainUITopActivity.Commit()
return MainUITopActivity
