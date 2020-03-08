local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TopFloatBtnBase = require("Main.MainUI.ui.TopFloatBtnBase")
local GUIUtils = require("GUI.GUIUtils")
local CarnivalModule = require("Main.Carnival.CarnivalModule")
local ActivityInterface = require("Main.activity.ActivityInterface")
local CarnivalUtils = require("Main.Carnival.CarnivalUtils")
local CarnivalEntry = Lplus.Extend(TopFloatBtnBase, MODULE_NAME)
local def = CarnivalEntry.define
local instance
def.static("=>", CarnivalEntry).Instance = function()
  if instance == nil then
    instance = CarnivalEntry()
  end
  return instance
end
def.override("=>", "boolean").IsOpen = function(self)
  return CarnivalModule.Instance():IsOpen(false)
end
def.override().OnShow = function(self)
  self:UpdateNotifyBadge()
  self:_HandleEventListeners(true)
end
def.override().OnHide = function(self)
  self:_HandleEventListeners(false)
end
def.method().UpdateNotifyBadge = function(self)
  local Img_Red = self.m_node:FindDirect("Img_Red")
  if Img_Red then
    local bNeedReddot = self:HaveActivityRedot()
    GUIUtils.SetActive(Img_Red, bNeedReddot)
  end
end
def.method("=>", "boolean").HaveActivityRedot = function(self)
  local activityInterface = ActivityInterface.Instance()
  local hasNew = false
  if CarnivalUtils.ContainCarnivalActivity(activityInterface._newLevelOpenActivitiesVector) or CarnivalUtils.ContainCarnivalActivity(activityInterface._newTimeOpenActivitiesVector) or CarnivalUtils.ContainCarnivalActivity(activityInterface._newFestivalActivitiesVector) then
    hasNew = true
  end
  if hasNew == false then
    hasNew = CarnivalUtils.ContainCarnivalActivity(activityInterface._importantActivitiesVector)
  end
  if hasNew == false then
    local redotActivies = {}
    for i, v in pairs(activityInterface.activityRedPoint) do
      if v then
        table.insert(redotActivies, i)
      end
    end
    hasNew = CarnivalUtils.ContainCarnivalActivity(redotActivies)
  end
  return hasNew
end
def.override("string").onClick = function(self, id)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_CARNIVAL_CLICK, nil)
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.CARNIVAL, gmodule.notifyId.CARNIVAL.CARNIVAL_REDDOT_UPDATE, CarnivalEntry.OnNotifyUpdate)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ImportantActivityChanged, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, CarnivalEntry.OnActivityChanged)
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, CarnivalEntry.OnActivityChanged)
  end
end
def.static("table", "table").OnNotifyUpdate = function(params, context)
  if instance then
    instance:UpdateNotifyBadge()
  end
end
def.static("table", "table").OnActivityChanged = function()
  if instance then
    instance:UpdateNotifyBadge()
  end
end
return CarnivalEntry.Commit()
