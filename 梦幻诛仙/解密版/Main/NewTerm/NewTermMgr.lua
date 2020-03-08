local Lplus = require("Lplus")
local NewTermData = require("Main.NewTerm.data.NewTermData")
local NewTermUtils = require("Main.NewTerm.NewTermUtils")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local NewTermMgr = Lplus.Class("NewTermMgr")
local def = NewTermMgr.define
local instance
def.static("=>", NewTermMgr).Instance = function()
  if instance == nil then
    instance = NewTermMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, NewTermMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, NewTermMgr.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, NewTermMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, NewTermMgr.OnDoActivity)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, NewTermMgr.OnAchievementChange)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, NewTermMgr.OnAchievementsInit)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, NewTermMgr.OnActivityClose)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, NewTermMgr.OnClickMapFindpath)
end
def.static("table", "table").OnLeaveWorld = function(param, context)
  NewTermData.Instance():OnLeaveWorld(param, context)
end
def.static("table", "table").OnFeatureOpenInit = function(param, context)
  NewTermMgr.UpdateActivityIDIPState()
  NewTermMgr.UpdateAchievementsAwards(true)
end
def.static("table", "table").OnFeatureOpenChange = function(param, context)
  if param.feature == ModuleFunSwitchInfo.TYPE_ACTIVITY_ACHIEVEMENT then
    NewTermMgr.UpdateActivityIDIPState()
    NewTermMgr.UpdateAchievementsAwards(false)
    if false == param.open then
      local NewTermPanel = require("Main.NewTerm.ui.NewTermPanel")
      if NewTermPanel.Instance():IsShow() then
        NewTermPanel.Instance():DestroyPanel()
      end
    end
  end
end
def.static().UpdateActivityIDIPState = function()
  local actAchievementsCfgs = NewTermData.Instance():GetActAchievementsCfgs()
  if actAchievementsCfgs then
    local bOpen = require("Main.NewTerm.NewTermModule").Instance():IsOpen(false)
    for actId, actAchieveCfg in pairs(actAchievementsCfgs) do
      if bOpen then
        ActivityInterface.Instance():removeCustomCloseActivity(actId)
      else
        ActivityInterface.Instance():addCustomCloseActivity(actId)
      end
    end
  end
end
def.static("table", "table").OnDoActivity = function(param, context)
  local activityId = param and param[1]
  if activityId then
    local actDisplayCfg = NewTermData.Instance():GetDisplayCfg(activityId)
    local actAchieveCfg = NewTermData.Instance():GetActAchievementsCfg(activityId)
    if actDisplayCfg and actAchieveCfg and require("Main.NewTerm.NewTermModule").Instance():IsOpen(true) then
      local NewTermPanel = require("Main.NewTerm.ui.NewTermPanel")
      NewTermPanel.ShowPanel(actDisplayCfg, actAchieveCfg)
    end
  end
end
def.static("table", "table").OnAchievementChange = function(param, context)
  local activityId = param and param[1] or 0
  local actAchieveCfg = NewTermData.Instance():GetActAchievementsCfg(activityId)
  NewTermMgr.CheckAchievementAward(actAchieveCfg, false)
end
def.static("table", "table").OnAchievementsInit = function(param, context)
  local activityId = param and param[1] or 0
  local actAchieveCfg = NewTermData.Instance():GetActAchievementsCfg(activityId)
  NewTermMgr.CheckAchievementAward(actAchieveCfg, true)
end
def.static("boolean").UpdateAchievementsAwards = function(bInit)
  local actAchievementsCfgs = NewTermData.Instance():GetActAchievementsCfgs()
  if actAchievementsCfgs then
    for actId, actAchieveCfg in pairs(actAchievementsCfgs) do
      NewTermMgr.CheckAchievementAward(actAchieveCfg, bInit)
    end
  end
end
def.static("table", "boolean").CheckAchievementAward = function(actAchieveCfg, bInit)
  if actAchieveCfg then
    local activityId = actAchieveCfg.activityId
    local bOpen = require("Main.NewTerm.NewTermModule").Instance():IsOpen(false)
    local bRed = false
    if bOpen then
      if NewTermData.Instance():HasUnfetchedAward(actAchieveCfg) then
        bRed = true
      else
        bRed = false
      end
    else
      bRed = false
    end
    if bRed or not bInit then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {activityId = activityId, isShowRedPoint = bRed})
    end
  end
end
def.static("table", "table").OnActivityClose = function(param, context)
  local activityId = param and param[1] or 0
  local NewTermPanel = require("Main.NewTerm.ui.NewTermPanel")
  if NewTermPanel.Instance():IsShow() and NewTermPanel.Instance():GetCurActivityId() == activityId then
    NewTermPanel.Instance():DestroyPanel()
  end
end
def.static("table", "table").OnClickMapFindpath = function(param, context)
end
NewTermMgr.Commit()
return NewTermMgr
